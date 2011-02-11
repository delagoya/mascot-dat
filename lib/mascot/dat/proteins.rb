module Mascot
  class DAT
    class Proteins
      class ProteinEntry < Struct.new(:accession, :mr,:desc); end
      PROT_REGEXP = /(.+)\=(\d+\.\d+),(.+)/
      include Enumerable

      # Example proteins section
      #
      # ––gc0p4Jq0M2Yt08jU534c0p
      # Content-Type: application/x-Mascot; name=”proteins”
      # “accession string”=protein mass, “title text”
      # ...

      def initialize(dat_file,byteoffset,cache_index=true)
        @byteoffset = byteoffset
        @file = File.new(dat_file, 'r')
        @file.pos = byteoffset
        @idx = {}
        if cache_index
          index_protein_positions
        end
      end

      def rewind
        @file.pos = @byteoffset
      end

      def protein(accession)
        @file.pos = @idx[accession] if accession
        next_entry
      end

      def next_entry
        return nil if @file.pos >= @endbytepos
        parse_entry(@file.readline)
      end


      def each
        while @file.pos < @endbytepos
          yield next_entry
        end
      end


      private
      def parse_entry(line)
        line.chomp =~ PROT_REGEXP
        ProteinEntry.new(:accession => $1, :mr => $2, :desc => $3)
      end

      def index_protein_positions
        boundary_line = @file.readline
        @boundary= /#{boundary_line}/
        @file.each do |line|
          break if line =~ @boundary
          acc, rest = line.split("=",2)
          @idx[acc] = @file.pos - line.length
        end
        @endbytepos = @file.pos = boundary_line.length
        rewind
      end

    end
  end
end