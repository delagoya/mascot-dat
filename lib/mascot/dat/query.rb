module Mascot
  class DAT

    # A class to represent mass spectrum query objects in Mascot DAT files.
    # Here is an example:
    #
    #     --gc0p4Jq0M2Yt08jU534c0p
    #     Content-Type: application/x-Mascot; name="query3"
    #
    #     title=253%2e131203405971_503
    #     rtinseconds=503
    #     index=5
    #     charge=2+
    #     mass_min=88.063115
    #     mass_max=392.171066
    #     int_min=6.064e+05
    #     int_max=6.064e+05
    #     num_vals=10
    #     num_used1=-1
    #     Ions1=88.063115:6.064e+05,196.589171:6.064e+05,331.143454:6.064e+05,392.171066:6.064e+05,114.570773:6.064e+05,228.134269:6.064e+05,139.567707:6.064e+05,278.128138:6.064e+05,166.075365:6.064e+05,175.118953:6.064e+05
    #
    # Things to note are:
    #
    #  * the spectrum title is encoded to produce nice output in HTML
    #  * the m/z and intensity values are given as pairs of values
    #  * the m/z and intensity values are not in increasing values of m/z
    #
    # This parser accounts for these in the attributes like so:
    #
    #  * spectrum title is de-encoded
    #  * the pairs of m/z and intensity are accessible via the {#peaks} method
    #  * the {#peaks} are ordered in accordance to increasing m/z
    #  * there are {#mz} and {#intensity} methods to get the individual array of values for each
    #
    class Query
      # The name of the query in Mascot DAT file, e.g. the MIME section header
      attr_reader :name
      # The spectrum title from the source mass spectrum file
      attr_reader :title
      # No clue what this is
      attr_reader :index
      # Retention time in seconds
      attr_reader :rtinseconds
      # Charge state of the parent MS1 ion
      attr_reader :charge
      # The minimum m/z of the values
      attr_reader :mass_min
      # The maximum m/z of the values
      attr_reader :mass_max
      # The minimum intensity of the values
      attr_reader :int_min
      # The maximum intensity of the values
      attr_reader :int_max
      # The number of peaks
      attr_reader :num_vals
      # No clue what this is
      attr_reader :num_used1
      # An Array of [m/z, intensity] tuples, ordered by increasing m/z values
      attr_reader :peaks
      # An Array of m/z values, ordered by increasing m/z
      attr_reader :mz
      # An Array of intensity values, ordered by the corresponding m/z value in the {#mz} Array
      attr_reader :intensity

      # All other attributes from DAT query sections not covered above
      attr_reader :attributes

      def initialize(query_str)
        query_str.split(/\n/).each do |l|
          next unless l =~ /(\w+)\=(.+)$/
          k,v = $1,$2
          case k
          when "name"
            @name = v.gsub('"','')
          when "title"
            @title = URI.decode(v)
          when "index"
            @index = v.to_i
          when "rtinseconds"
            @rtinseconds = v.to_i
          when "charge"
            @charge = v
          when "mass_min"
            @mass_min = v.to_f
          when "mass_max"
            @mass_max = v.to_f
          when "int_min"
            @int_min = v.to_f
          when "int_max"
            @int_max = v.to_f
          when "num_vals"
            @num_vals = v.to_i
          when "num_used1"
            @num_used1 = v.to_i
          when "Ions1"
            parse_ions1(v)
          else
            @attributes[k.to_sym] = v
          end
        end
      end

      private
      def parse_ions1(ions1)
        @peaks = []
        ions1.split(",").collect do |mzpair|
          @peaks <<  mzpair.split(":").collect {|e| e.to_f}
        end
        # now sort the mz_tmp array as ascending m/z, and return the array
        @peaks.sort!
        # once sorted by increasing m/z, populate the individual arrays
        @mz = @peaks.collect {|p| p[0]}
        @intensity = @peaks.collect {|p| p[1]}
      end
    end
  end
end

