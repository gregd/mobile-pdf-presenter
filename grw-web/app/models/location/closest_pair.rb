module Location

  # http://rosettacode.org/wiki/Closest-pair_problem#Ruby
  class ClosestPair
    include Geokit::Mappable

    attr_accessor :x, :y, :ob

    def initialize(ob)
      self.x = ob.lat
      self.y = ob.lng
      self.ob = ob
    end

    def to_lat_lng
      Geokit::LatLng.new(self.x, self.y)
    end

    def self.distance(p1, p2)
      # simplification but it should work in most cases
      p1.distance_to(p2)
    end

    def self.bruteforce(points)
      mindist, minpts = Float::MAX, []
      points.length.times do |i|
        (i+1).upto(points.length - 1) do |j|
          dist = distance(points[i], points[j])
          if dist < mindist
            mindist = dist
            minpts = [points[i], points[j]]
          end
        end
      end
      [mindist, minpts]
    end

    def self.recursive(points)
      if points.length <= 3
        return bruteforce(points)
      end
      xP = points.sort_by {|p| p.x}
      mid = (points.length / 2.0).ceil
      pL = xP[0,mid]
      pR = xP[mid..-1]
      dL, pairL = recursive(pL)
      dR, pairR = recursive(pR)
      if dL < dR
        dmin, dpair = dL, pairL
      else
        dmin, dpair = dR, pairR
      end
      yP = xP.find_all {|p| (pL[-1].x - p.x).abs < dmin}.sort_by {|p| p.y}
      closest = Float::MAX
      closestPair = []
      0.upto(yP.length - 2) do |i|
        (i+1).upto(yP.length - 1) do |k|
          break if (yP[k].y - yP[i].y) >= dmin
          dist = distance(yP[i], yP[k])
          if dist < closest
            closest = dist
            closestPair = [yP[i], yP[k]]
          end
        end
      end
      if closest < dmin
        [closest, closestPair]
      else
        [dmin, dpair]
      end
    end

  end

end


