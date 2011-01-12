module Mascot
  class DAT::Masses

    # An array of mass deltas. Order corresponds to parameter IT_MODS
    attr_reader :deltas

    # An array of mass deltas. Order corresponds to parameter MODS
    attr_reader :fixed_mods

    # A Hash of the mass table. E.g.
    #
    #     self.masstable[:Hydorgen] #=> 1.007825
    #
    attr_reader :masstable

    def initialize masses_section
      @masstable = {}
      @deltas = []
      @fixed_mods = []

      masses_section.split("\n").each do |l|
        k,v = l.split("=")
        next unless k && v
        case k
        when /delta(\d+)/
          idx = $1.to_i - 1
          @deltas[idx] = v.split(",")
          @deltas[idx][0] = @deltas[idx][0].to_f
          @masstable[k.to_sym] = @deltas[idx][0]
        when /FixedMod(.*)(\d+)/
          idx = $2.to_i - 1
          if $1.empty?
            # new fixed mod record
            @fixed_mods[idx] = v.split(",")
            @fixed_mods[idx][0] = @fixed_mods[idx][0].to_f
            @masstable[k.to_sym] = @fixed_mods[idx][0]
          else
            # append the modified residue to the array
            @fixed_mods[idx] << v
          end
        else
          @masstable[k.to_sym] = v.to_f
        end
      end
    end
  end
end
