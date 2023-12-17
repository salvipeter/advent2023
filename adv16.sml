fun step (x, y) dir =
    let val (dx, dy) = List.nth ([(0,~1),(1,0),(0,1),(~1,0)], dir)
    in (x + dx, y + dy) end

val heatmap =
    let val f = TextIO.openIn "adv16.txt"
    in let fun loop acc = 
               case TextIO.inputLine f of
                   NONE   => ( TextIO.closeIn f
                             ; (Vector.fromList o rev) acc
                             )
                 | SOME s => loop (s :: acc)
       in loop [] end
    end

fun get (x, y) =
    let val n = Vector.length heatmap
    in if x < 0 orelse y < 0 orelse x >= n orelse y >= n
       then NONE
       else SOME (String.sub (Vector.sub (heatmap, y), x))
    end

(* SML/NJ Util library *)
structure PairOrd: ORD_KEY =
  struct
    type ord_key = int * int
    fun compare ((a, b), (c, d)) =
        case Int.compare (a, c) of
            LESS    => LESS
          | GREATER => GREATER
          | EQUAL   => Int.compare (b, d)
  end
structure PairMap: ORD_MAP = RedBlackMapFn(PairOrd)

fun simulate pos dir acc =
    case get pos of
        NONE   => acc
      | SOME c =>
        let val ds = PairMap.lookup (acc, pos) handle NotFound => []
            fun f ds =
                let val acc' = PairMap.insert (acc, pos, ds)
                in let val (dir', acc'') =
                           case c of
                               #"/"  => (List.nth ([1,0,3,2], dir), acc')
                             | #"\\" => (List.nth ([3,2,1,0], dir), acc')
                             | #"-"  => if dir mod 2 = 1 then (dir, acc')
                                        else (3, simulate pos 1 acc')
                             | #"|"  => if dir mod 2 = 0 then (dir, acc')
                                        else (2, simulate pos 0 acc')
                             | #"."  => (dir, acc')
                             | _     => raise Domain
                   in simulate (step pos dir') dir' acc'' end
                end
        in case List.find (fn d => d = dir) ds of
               NONE   => f (dir :: ds)
             | SOME _ => acc
        end

fun energy pos dir = PairMap.numItems (simulate pos dir PairMap.empty)

val _ =
    let val size = Vector.length heatmap
        fun f i =
            [energy (i,        size - 1) 0,
             energy (0,        i)        1,
             energy (i,        0)        2,
             energy (size - 1, 0)        3]
    in let val xs = List.tabulate (size, f)
       in print ((Int.toString o List.nth) (hd xs, 1) ^ " " ^
                 (Int.toString o foldl Int.max 0 o List.concat) xs ^ "\n")
       end
    end
