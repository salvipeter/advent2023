#include <array>
#include <fstream>
#include <iostream>
#include <map>
#include <queue>
#include <set>

using Pos = std::array<int, 2>;
using PosDir = std::array<int, 3>;
using Edge = std::pair<PosDir, int>;

std::vector<std::string> map;
std::map<PosDir, std::vector<Edge>> edges;

Pos step(Pos pos, int dir) {
  static Pos d[] = { {0,-1}, {1,0}, {0,1}, {-1,0} };
  pos[0] += d[dir][0];
  pos[1] += d[dir][1];
  return pos;
}

int get(const Pos &pos) {
  if (pos[0] < 0 || pos[1] < 0 ||
      (size_t)pos[0] >= map.size() || (size_t)pos[1] >= map.size())
    return 0;
  return map.at(pos[1])[pos[0]] - '0';
}

std::pair<PosDir, int> weightedStep(Pos pos, int dir, int n) {
  int sum = 0;
  for (int i = 0; i < n; ++i) {
    pos = step(pos, dir);
    int w = get(pos);
    if (w == 0)
      return { {0,0,0}, 0 };
    sum += w;
  }
  return { { pos[0], pos[1], dir }, sum };
}

int shortestPath(const Pos &from, const Pos &to) {
  std::map<PosDir, int> cost;
  std::set<PosDir> visited;
  auto compare = [&](const PosDir &a, const PosDir &b) {
    return cost.at(a) > cost.at(b);
  };
  std::priority_queue<PosDir, std::vector<PosDir>, decltype(compare)>
    queue(compare);
  PosDir start = { from[0], from[1], -1 };
  cost[start] = 0;
  queue.push(start);
  while (!queue.empty()) {
    auto p0 = queue.top();
    queue.pop();
    if (visited.contains(p0))
      continue;
    int w0 = cost.at(p0);
    for (const auto &[p, w] : edges.at(p0)) {
      if (visited.contains(p))
        continue;
      if (!cost.contains(p) || w0 + w < cost.at(p)) {
        cost[p] = w0 + w;
        queue.push(p);
      }
    }
    visited.insert(p0);
  }
  int min = -1;
  for (int i = 0; i < 4; ++i) {
    PosDir p = { to[0], to[1], i };
    if (!cost.contains(p))
      continue;
    int d = cost.at(p);
    if (min < 0 || d < min)
      min = d;
  }
  return min;
}

int main(int argc, char **argv) {
  int min = 1, max = 3;
  if (argc == 2) {
    min = 4;
    max = 10;
  }
  std::ifstream f("adv17.txt");
  while (true) {
    std::string s;
    std::getline(f, s);
    if (f.eof())
      break;
    map.push_back(s);
  }
  f.close();
  int size = map.size() - 1;
  for (int x = 0; x <= size; ++x) {
    for (int y = 0; y <= size; ++y) {
      Pos p = { x, y };
      for (int d = 0; d < 4; ++d) {
        PosDir pd = {x, y, d};
        edges[pd] = std::vector<Edge>();
        int d1 = (d + 1) % 4;
        int d2 = (d + 3) % 4;
        for (int i = min; i <= max; ++i) {
          auto ws1 = weightedStep(p, d1, i);
          auto ws2 = weightedStep(p, d2, i);
          if (ws1.second != 0)
            edges[pd].push_back(ws1);
          if (ws2.second != 0)
            edges[pd].push_back(ws2);
        }
      }
    }
  }
  edges[{0,0,-1}] = edges[{0,0,0}];
  edges[{0,0,-1}].insert(edges[{0,0,-1}].end(),
                         edges[{0,0,1}].begin(), edges[{0,0,1}].end());

  printf("%d\n", shortestPath({0,0}, {size,size}));
}
