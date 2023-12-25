#include <fstream>
#include <iostream>
#include <map>
#include <sstream>
#include <string>
#include <vector>

#include <boost/graph/adjacency_list.hpp>
#include <boost/graph/graph_traits.hpp>
#include <boost/graph/one_bit_color_map.hpp>
#include <boost/graph/stoer_wagner_min_cut.hpp>
#include <boost/property_map/property_map.hpp>
#include <boost/typeof/typeof.hpp>

struct edge_t {
    size_t first;
    size_t second;
};

using Graph =
  boost::adjacency_list<boost::vecS, boost::vecS, boost::undirectedS,
                        boost::no_property,
                        boost::property<boost::edge_weight_t, int>>;
using WeightMap =
  boost::property_map<Graph, boost::edge_weight_t>::type;
using Weight = boost::property_traits<WeightMap>::value_type;

int main(int argc, char **argv) {
  std::vector<edge_t> edges;
  size_t count = 0;

  std::map<std::string, size_t> names;
  std::ifstream f("adv25.txt");
  while (true) {
    std::string s;
    std::getline(f, s);
    if (f.eof())
      break;
    std::istringstream ss(s);
    std::string a, b;
    ss >> a;
    a.erase(a.find(':'));
    if (!names.contains(a))
      names[a] = count++;
    while (!ss.eof()) {
      ss >> b;
      if (!names.contains(b))
        names[b] = count++;
      edges.emplace_back(names[a], names[b]);
    }
  }
  f.close();

  std::vector<Weight> weights(edges.size(), 1);
  Graph g(edges.begin(), edges.end(), weights.begin(), count, edges.size());
  auto parities =
    boost::make_one_bit_color_map(num_vertices(g), get(boost::vertex_index, g));
  boost::stoer_wagner_min_cut(g, get(boost::edge_weight, g),
                              boost::parity_map(parities));
  size_t n = 0;
  for (size_t i = 0; i < num_vertices(g); ++i)
    if (get(parities, i))
      n++;
  std::cout << n * (count - n) << std::endl;
}
