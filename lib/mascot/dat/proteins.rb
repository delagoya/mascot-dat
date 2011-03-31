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
      attr_accessor :byteoffset, :dat_file, :endbytepos, :idx

      def initialize(dat_file,byteoffset,cache_index=true)
        @byteoffset = byteoffset
        @dat_file = File.new(dat_file, 'r')
        @dat_file.pos = byteoffset
        @endbytepos = @dat_file.stat.size
        @idx = {}
        if cache_index
          index_protein_positions
        end
      end

      def rewind
        @dat_file.pos = @byteoffset
      end

      def protein(accession)
        @dat_file.pos = @idx[accession] if accession
        next_entry
      end

      def next_entry
        return nil if @dat_file.pos >= @endbytepos
        parse_entry(@dat_file.readline)
      end


      def each
        while @dat_file.pos < @endbytepos
          yield next_entry
        end
      end


      private
      def parse_entry(line)
        line.chomp =~ PROT_REGEXP
        pe = ProteinEntry.new()
        pe.accession = $1
        pe.mr = $2
        pe.desc = $3
        pe
      end

      def index_protein_positions
        boundary_line = @dat_file.readline
        @boundary= /#{boundary_line}/
        @dat_file.each do |line|
          break if line =~ @boundary
          acc, rest = line.split("=",2)
          @idx[acc] = @dat_file.pos - line.length
        end
        @endbytepos = @dat_file.pos = boundary_line.length
        rewind
      end

    end
  end
end