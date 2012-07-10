require 'csv'
module Mascot
  class DAT
    # A iterator for the peptide spectrum match results of a Mascot DAT file.
    # As opposed to the other sections of a DAT file, you don't really want to
    # access this section in memory at once. It is often quite large and
    # needs to be accessed using the provided Enumerable or random access methods.
    class Peptides
      include Enumerable
      # A nested Hash index of the byte offset positions for the peptide-spectrum-match entries.
      # The keys of the index are the query and peptide rank (Fixnum), the structure of which is:
      #    { query_number => { peptide_rank => byte_position } }
      # To access a particular entry, it is better to use the {#psm} method.
      # @return [Hash{ Fixnum => Hash{ Fixnum => Fixnum }}] The nested hash of query peptide match byte offsets
      attr_reader :psmidx

      # @param dat [Mascot::DAT] Source DAT file
      # @param section_label [Symbol] Section header, one of :peptides or :decoy_peptides
      # @param cache_psm_index [Boolean] Whether to cache the PSM index
      def initialize(dat, section_label, cache_psm_index=true)
        # create our own filehandle, since other operations may interfere with the
        @dat = Mascot::DAT.open(dat.dat_file.path)
        @filehandle = @dat.dat_file
        @section_label = section_label
        self.rewind
        @curr_psm = [1,1]
        @psmidx = {}
        @endbytepos = Float::INFINITY
        if cache_psm_index
          index_psm_positions()
        end
      end

      # Rewind the cursor to the start of the peptides section (e.g. q1_p1=...)
      def rewind
        @dat.goto(@section_label)
        1.upto(2) { @filehandle.readline }
      end

      # Return a specific {Mascot::DAT::PSM} identified for query <code>q</code> and peptide number <code>p</code>
      # @param query_number [Fixnum]
      # @param rank [Fixnum]
      # @return [Mascot::DAT::PSM]
      # @raise [Exception] if given an invalid q,p coordinate
      # @example my_dat.peptides.psm(1,1) # => Mascot::DAT::PSM for query 1 peptide 1
      def psm query_number,rank
        if @psmidx[query_number] and @psmidx[query_number][rank]
          @filehandle.pos  =  @psmidx[query_number][rank]
          next_psm
        else
          raise Exception.new "Invalid PSM specification (#{q},#{p})"
        end
      end

      # Returns the next {Mascot::DAT::PSM} from the DAT file. If there is no other PSM, then it returns nil.
      # @return [Mascot::DAT::PSM, NilClass]
      def next_psm
        if @filehandle.pos >= @endbytepos
          return nil
        end
        # get the initial values for query & rank
        buffer = [@filehandle.readline.chomp]
        buffer[0] =~ /q(\d+)_p(\d+)/
        q,p = $1, $2
        @curr_psm = [q,p]
        prev_pos = @filehandle.pos
        @filehandle.each do |l|
          l.chomp!
          # break if we have reached the boundary
          if l =~ @boundary
            @endbytepos = @filehandle.pos - @dat.boundary_string.length
            break
          end
          # break if we are on another PSM
          break unless l =~ /^q#{q}_p#{p}/
          buffer << l
          prev_pos = @filehandle.pos
        end
        # rewind the cursor to the last hit
        @filehandle.pos = prev_pos
        # return the new PSM
        Mascot::DAT::PSM.new(buffer)
      end

      # Iterate through all of the {Mascot::DAT::PSM} entries in the DAT file.
      # @yield [Mascot::DAT::PSM]
      def each
        self.rewind
        while psm = self.next_psm
          yield psm
        end
      end

      private
      # Index the byte offsets of the PSMs
      # @private
      def index_psm_positions
        # create an in-memroy index of PSM byteoffsets
        q,p  = 0,0
        # move the cursor past the boundary line
        @filehandle.readline
        @filehandle.each do |line|
          break if line =~ @dat.boundary
          line =~ /q(\d+)_p(\d+)/
          qq,pp= $1.to_i, $2.to_i
          next if q == qq && p == pp
          q,p = qq,pp
          unless @psmidx.has_key?(q)
            @psmidx[q] = {}
          end
          @psmidx[q][p] = @filehandle.pos - line.length
        end
        @endbytepos = @filehandle.pos - @dat.boundary_string.length
        self.rewind
      end
    end
  end
end