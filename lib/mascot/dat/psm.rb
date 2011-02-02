module Mascot
  class DAT
    class PSM
      ATTRS = [:query,:rank,:missed_cleavages,:mr, :delta,
        :num_ions_matched,:pep,:ions1,:var_mods_str,:score,
        :ion_series_str,:ions2,:ions3,:proteins,:dbs,:terms,:attrs]

      ATTRS.each do |a|
        attr_accessor a
      end

      def initialize(*opts)
        @attrs = {}

        if opts.kind_of? Hash
          opts.keys.each do |k|
            if ATTRS.index(k.to_sym)
              eval "@#{k} = #{opts[k]}"
            end
          end
        end
      end

      def ==(other)
        is_eql = true
        ATTRS.each do |a|
          if self.send(a) != other.send(a)
            is_eql = false
            break
          end
        end
        is_eql
      end
    end
  end
end