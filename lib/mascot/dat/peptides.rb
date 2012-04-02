require 'csv'
module Mascot
  # A parser for the peptide spectrum match results of a Mascot DAT file.
  # As opposed to the other sections of a DAT file, you don't really want to
  # access this section as one big chunk in memory. It is often quite large and
  # needs to be accessed using Enumerable methods.
  #
  # From the Mascot documentation, results are CSV list with the following information
  #     q1_p1_db=01  # two digit integer of the search DB index, zero filled and retarded.
  #     q1_p1=missed cleavages, (–1 indicates no match)
  #           peptide Mr,
  #           delta,
  #           number of ions matched,
  #           peptide string,
  #           peaks used from Ions1,
  #           variable modifications string,
  #           ions score,
  #           ion series found,
  #           peaks used from Ions2,
  #           peaks used from Ions3;
  #           “accession string”:frame number:start:end:multiplicity, # data for first protein
  #           “accession string”:frame number:start:end:multiplicity, # data for second protein, etc.
  #     q1_p1_et_mods=modification mass,
  #                   neutral loss mass,
  #                   modification description
  #     q1_p1_primary_nl=neutral loss string
  #     q1_p1_drange=startPos:endPos
  #     q1_p1_terms=residue,residue:residue,residue # flanking AA for each protien, in order
  #


  class DAT
    class Peptides
      include Enumerable
      # A hash of the index positions for the peptide PSM matches.
      # Keys arr
      attr_reader :psmidx, :byteoffset, :endbytepos

      # To create a peptides enumerable, you need to pass in the dat file handle and
      # the byte offset of the peptides section.
      def initialize(dat_file, byteoffset, cache_psm_index=true)
        @byteoffset = byteoffset
        @endbytepos = nil

        @file = dat_file

        @file.pos = @byteoffset
        @curr_psm = [1,1]
        @psmidx = []
        @cache_psm_index = cache_psm_index
        index_psm_positions()
      end

      def index_psm_positions
        # create an in-memroy index of PSM byteoffsets
        q,p  = 0
        boundary_line = @file.readline
        @boundary   = Regexp.new(boundary_line)
        @file.each do |line|
          break if line =~ @boundary
          if @cache_psm_index
            line =~ /q(\d+)_p(\d+)/
            i,j = $1.to_i, $2.to_i
            next if q == i && p == j
            unless @psmidx[i].kind_of? Array
              q = i
              @psmidx[q] = []
            end
            @psmidx[i][j] = @file.pos - line.length
            q,p = i,j
          end
        end
        @endbytepos = @file.pos - boundary_line.length
        rewind
      end

      def rewind
        @file.pos = @byteoffset + @boundary.length
      end

      def psm q,p
        @file.pos  =  @psmidx[q][p]
        next_psm
      end

      def next_psm
        return nil if @file.pos >= @endbytepos
        # get the initial values for query & rank
        tmp = []
        tmp << @file.readline.chomp
        k,v = tmp[0].split "="
        # skip when there are no peptides (value equals -1)
        return nil if v == "-1"

        tmp[0] =~ /q(\d+)_p(\d+)/
        q = $1
        p = $2

        tmp_pos = @file.pos
        @file.each do |l|
          break if l =~ @boundary
          break unless l =~ /^q#{q}_p#{p}/
          tmp << l.chomp
          tmp_pos = @file.pos
        end
        @file.pos = tmp_pos

        Mascot::DAT::PSM.parse(tmp)
      end

      def each
        while @file.pos < @endbytepos
          psm = next_psm()
          next if psm.nil?
          yield psm
        end
      end
    end
  end
end