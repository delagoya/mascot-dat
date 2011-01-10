module Mascot
  class DAT
    class Enzyme
      # example enzyme section
      #
      #    --gc0p4Jq0M2Yt08jU534c0p
      #    Content-Type: application/x-Mascot; name="enzyme"
      #
      #    Title:V8-DE/Trypsin
      #    Independent:0
      #    SemiSpecific:0
      #    Cleavage[0]:KR
      #    Restrict[0]:P
      #    Cterm[0]
      #    Cleavage[1]:BDEZ
      #    Restrict[1]:P
      #    Cterm[1]
      #    *
      attr_accessor :title, :independent, :semi_specific,
      :cleavages, :restrictions, :terminals

      def initialize(enz_section)
        @title = ""
        @independent = false
        @semi_specific = false
        @cleavages = []
        @restrictions = []
        @terminals  = []

        enz_section.split(/\n/).each do |line|
          k,v = line.chomp.split(":")
          case k
          when "Title"
            @title = v
          when "Independent"
            @independent = v.to_i > 0 ? true : false
          when "SemiSpecific"
            @semi_specific = v.to_i > 0 ? true :false
          when /^Cleavage\[?(\d?)\]?/
            if $1
              @cleavages[$1.to_i] = v
            else
              @cleavages << v
            end
          when /^Restrict\[?(\d?)\]?/
            if $1
              @restrictions[$1.to_i] = v
            else
              @restrictions << v
            end
          when /^(\w)term\[?(\d?)\]?/
            idx = $2.empty ? 0 : $2.to_i
            @terminals[idx] = $1
          end
        end
      end
    end
  end
end
