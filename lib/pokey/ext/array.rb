
class Array

    # get all permutations of n size
    # eg, if array has 6 elements and n = 5
    # an array of 5 element permutations will be returned
    def perm(n = size)
        if size < n or n < 0
        elsif n == 0
            yield([])
        else
            self[1..-1].perm(n - 1) do |x|
                (0...n).each do |i|
                    yield(x[0...i] + [first] + x[i..-1])
                end
            end
            self[1..-1].perm(n) do |x|
                yield(x)
            end
        end
    end
  
end