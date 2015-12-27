require "vptree/version"
require 'distance_measures'
require 'algorithms'

module Vptree

  class FixedLengthQueue < Containers::PriorityQueue
    def initialize(limit = 4) # 4 for example
      super()
      @limit = limit
    end

    def max_priority
      @heap.next_key
    end

    def push(value, priority)
      if size < @limit
        super(value, priority)
      else
        if priority < @heap.next_key
          pop
          super(value, priority)
        end
      end
    end

    def dump()
      size.times.map{ @heap.pop }
    end
  end

  class VPNode
    attr_accessor :is_block, :distance_measure, :data, :vp_point, :left_node, :right_node, :mu

    def initialize(data, options={}, &block)
      @data = data
      @is_block = block != nil
      @distance_measure = block || options[:distance_measure]  || :euclidean_distance
      @left_node = nil
      @right_node = nil
      @mu = 0
    end

    def setup(other_node)
      @is_block = other_node.is_block
      @distance_measure = other_node.distance_measure
    end

    def calc_dist(obj1, obj2)
      begin
        return  @is_block ? obj1.calc_distance(obj2, &@distance_measure) : obj1.calc_distance(obj2, @distance_measure)
      rescue
        return @is_block ? @distance_measure.call(obj1, obj2) : obj1.send(@distance_measure, obj2) # old fasion distance gem, for arrays only
      end

    end

    def separate()

      if @data.size <= 2
        @vp_point = @data.first
        @right_node = nil
        if @data.size == 2
          @mu = calc_dist(@data[0],@data[1])/2
          @left_node = VPNode.new([@data[1]])
        end
      else
        @vp_point = @data.sample
        # all sorted nodes
        next_node_data = @data.sort_by{ |a| calc_dist(a, @vp_point) }[1..-1]
        len = next_node_data.size
        r_points = next_node_data[0..(len/2 - 1)];
        l_points = next_node_data[(len/2)..-1]
        @mu = (calc_dist(r_points.last, @vp_point) + calc_dist(l_points.first, @vp_point))/2.0
        @right_node = VPNode.new(r_points)
        @left_node  = VPNode.new(l_points)
      end
      @right_node.setup(self) if @right_node
      @left_node.setup(self) if @left_node

      @right_node.separate if @right_node
      @left_node.separate if @left_node
      @data = nil
    end

  end

  class VPTree

    attr_accessor :root

    def initialize(data, options={}, &block)
      @data = data
      @is_block = block != nil
      @distance_measure = block || options[:distance_measure]  || :euclidean_distance
      @root = VPNode.new(data, options, &block)
    end

    def calc_dist(obj1, obj2)
      @is_block ? obj1.calc_distance(obj2, &@distance_measure) : obj1.calc_distance(obj2, @distance_measure)
    end


    def build_tree()
      @root.separate
    end

    def find_k_nearest(obj, k)
      tau = Float::INFINITY
      nodes_to_visit = Containers::Queue.new
      nodes_to_visit.push(@root)

      # fixed size array for nearest neightbors
      # sorted from closest to farthest neighbor
      neighbors = FixedLengthQueue.new(k)

      while nodes_to_visit.size() > 0 do
        node = nodes_to_visit.pop()
        d = calc_dist(obj, node.vp_point)
        if d < tau
          # store node.vp_point as a neighbor if it's closer than any other point
          # seen so far
          neighbors.push(node.vp_point, d)
          # shrink tau
          tau = neighbors.max_priority
        end
        # check for intersection between q-tau and vp-mu regions
        # and see which branches we absolutely must search

        if d < node.mu
          # the object is in mu range of Vintage Point
          nodes_to_visit.push(node.right_node) if node.right_node # d < node.mu + tau # permanent true
          nodes_to_visit.push(node.left_node) if node.left_node && d >= node.mu - tau # partial overlap
        else
          nodes_to_visit.push(node.left_node) if node.left_node # d >= node.mu - tau
          nodes_to_visit.push(node.right_node) if node.right_node && d < node.mu + tau # partial overlap
        end
      end

      return neighbors.dump
    end
  end
end
