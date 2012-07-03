module Mascot
  class DAT

    # A Hash of the mass table section. See the {#masstable masstable} instance method for details.
    class Masses
      # The main table of masses. Given the following examples from a DAT file:
      #
      #     W=186.079313
      #     X=111.000000
      #     Y=163.063329
      #     Z=128.550590
      #     Hydrogen=1.007825
      #     Carbon=12.000000
      #
      # You can access the value for Hydrogen as:
      #     mydat.masses.masstable[:Hydorgen] # => 1.007825
      # or
      #     mydat.masses.m[:Hydrogen] # => 1.007825
      # or
      #    mydat.masses.hydorgen # =>  1.007825
      attr_reader :masstable
      # def masstable
      #   @masstable
      # end
      alias_method :m, :masstable

      # A subset of the mass table defining the variable modications. For
      # example, given the following delta in a DAT file:
      #
      #     delta1=15.994915,Oxidation (M)
      #
      # Then the following gets defined:
      #
      #     @deltas = [[15.994915,"Oxidation (M)"], ... ]
      #
      attr_reader :deltas
      alias_method :mods, :deltas
      alias_method :d, :deltas

      # A subset of the mass table defining the fixed modifications. For
      # example:
      #
      #     FixedMod1=57.021464,Carbamidomethyl (C)
      #     FixedModResidues1=C
      #
      # Then the following gets defined:
      #
      #     @fixed_modifications = [[57.021464, "Carbamidomethyl (C)", "C"], ...]
      #
      attr_reader :fixed_modifications
      alias_method :fixed_mods, :fixed_modifications
      alias_method :f, :fixed_modifications

      def initialize masses_section
        @masstable = {}
        @deltas = []
        @fixed_modifications = []

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
              @fixed_modifications[idx] = v.split(",")
              @fixed_modifications[idx][0] = @fixed_modifications[idx][0].to_f
              @masstable[k.to_sym] = @fixed_modifications[idx][0]
            else
              # append the modified residue to the array
              @fixed_modifications[idx] << v
            end
          else
            @masstable[k.to_sym] = v.to_f
          end
          @masstable.keys.each do |m|
            self.class.send(:define_method,m, lambda { @masstable[m] })
          end
        end
      end
    end
  end
end
