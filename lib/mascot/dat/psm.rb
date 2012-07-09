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
      def self.parse psm_arr
        psm_result =  self.new()
        psm_arr.each do |l|
          next unless l =~ /^q/

          k,v = l.split "="
          case k
          when /^q(\d+)_p(\d+)$/
            psm_result.query = $1.to_i
            psm_result.rank = $2.to_i
            psm_vals, prots  = v.split(";")
            psm_vals = psm_vals.split(',')
            psm_result.missed_cleavages= psm_vals[0].to_i
            psm_result.mr              = psm_vals[1].to_f
            psm_result.delta           = psm_vals[2].to_f
            psm_result.num_ions_matched = psm_vals[3].to_i
            psm_result.pep             = psm_vals[4]
            psm_result.ions1           = psm_vals[5].to_i
            psm_result.var_mods_str    = psm_vals[6]
            psm_result.score           = psm_vals[7].to_f
            psm_result.ion_series_str  = psm_vals[8]
            psm_result.ions2           = psm_vals[9].to_i
            psm_result.ions3           = psm_vals[10].to_i

            # assign proteins
            psm_result.proteins = prots.split(",").map do |pe|
              acc,*other_vals =  pe.split(":")
              acc.gsub!(/\"/,'')
              [acc] + other_vals.map {|e| e.to_i }
            end
          when /db$/
            # split on 2 chars, call to_i
            psm_result.dbs = v.split(/(\d{2})/).grep(/^\d+$/) { |e| e.to_i }
          when /terms$/
            # for each protein, I have to add the term AA
            psm_result.terms = v.split(":").collect {|t| t.split(",") }
          else
            # returns the smaller key
            puts "****#{k}***"
            k_sym = k.slice(/q\d+_p\d+_?(.+)/,1).to_sym
            psm_result.attrs[k_sym] = v
          end
        end
        psm_result
      end
    end
  end
end