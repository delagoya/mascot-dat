require "uri"
require 'mascot/dat/enzyme'
require 'mascot/dat/header_info'
require 'mascot/dat/masses'
require 'mascot/dat/parameters'
require 'mascot/dat/peptides'
require 'mascot/dat/proteins'
require 'mascot/dat/psm'
require "mascot/dat/query"
require 'mascot/dat/search_databases'
require 'mascot/dat/summary'
require 'mascot/dat/version'

module Mascot
  # A parser for Mascot flat file results.
  #
  # <b> NOTE:</b> This parser creates another file
  # that indexes the byte position offsets of the various mime sections of
  # a DAT file. For some reason, DAT files indexes are the line numbers
  # within the file, making random access more difficult than it
  # needs to be.
  #
  # <b>If you do not want this index file created, you need to pass in
  #   <code> false</code> to the <code>cache_index</code> argument
  class DAT
    attr_reader :idx
    attr_reader :boundary
    attr_reader :boundary_string
    attr_reader :dat_file
    SECTIONS = ["summary", "decoy_summary", "et_summary", "parameters",
                "peptides", "decoy_peptides", "et_peptides",
                "proteins", "header", "enzyme", "taxonomy", "unimod",
                "quantitation", "masses", "mixture", "decoy_mixture", "index"]

    def initialize(dat_file_path, cache_index=true)
      @dat_file = File.open(dat_file_path)
      @idx = {}
      @boundary = nil
      @boundary_string = nil
      @cache_index = cache_index
      parse_index
    end

    def self.open(dat_file_path, cache_index=true)
      DAT.new(dat_file_path, cache_index)
    end

    def close
      @dat_file.close
    end

    # Return a specific query spectrum from the DAT file
    #
    # @param n  The query spectrum numerical index
    # @return  {Mascot::DAT::Query}
    def query(n)
      return Mascot::DAT::Query.new(self.read_section(:"query#{n}"))
    end
    alias_method :spectrum, :query

    # Go to a section of the Mascot DAT file
    def goto(key)
      if @idx.has_key?(key.to_sym)
        @dat_file.pos = @idx[key.to_sym]
      else
        raise Exception.new "Invalid DAT section \"#{key}\""
      end
    end

    # Read a section of the DAT file into memory. THIS IS NOT
    # RECOMMENDED UNLESS YOU KNOW WHAT YOU ARE DOING.
    #
    # @param key [String or Symbol] The section name
    # @return [String] The section of the DAT file as a String. The section
    #                  includes the MIME boundary and  content type
    #                  definition lines.
    def read_section(key)
      self.goto(key.to_sym)
      # read past the initial boundary marker
      tmp = @dat_file.readline
      @dat_file.each do |l|
        break if l =~ @boundary
        tmp << l
      end
      tmp
    end

    # Parse the enzyme information from the DAT file
    #
    # @return [Array<Mascot::DAT::Enzyme>]
    def enzyme
      @enzyme ||= Mascot::DAT::Enzyme.new(self.read_section(:enzyme))
    end
    # Parse the masses section of the  DAT file
    #
    # @return [Mascot::DAT::Masses]
    def masses
      @masses ||= Mascot::DAT::Masses.new(self.read_section(:masses))
    end
    # Parses parameters from DAT file
    # @return [Mascot::DAT::Parameters]
    def parameters
      @params ||= Mascot::DAT::Parameters.new(self.read_section(:parameters))
    end

    # Parses and return search databases from DAT file
    # @return [Mascot::DAT::SearchDatabases]
    def search_databases
      @search_databases ||= Mascot::DAT::SearchDatabases.new(parameters)
    end

    # Puts the IO cursor at the beginning of peptide result section. Returns an iterator/parser for PSM results
    #
    # @param cache_psm_index Whether to cache the positions of the PSMs. If you just want to iterate
    #                        through PSMs, you do not need to cache the index.
    # @return [Mascot::DAT::Peptides, NilClass]
    def peptides(cache_psm_index=true)
      Mascot::DAT::Peptides.new(self, :peptides, cache_psm_index)
    end

    # If the DAT file has a decoy section, puts the IO cursor at the beginning of decoy_peptide
    # result section and returns an iterator/parser for the decoy PSM results.
    # If no decoy section exists, it will return nil.
    #
    # @param cache_psm_index Whether to cache the positions of the PSMs. If you just want to iterate
    #                        through PSMs, you do not need to cache the index.
    # @return [Mascot::DAT::Peptides, NilClass]
    def decoy_peptides(cache_psm_index=true)
      if @idx.has_key? :decoy_peptides
        Mascot::DAT::Peptides.new(self,:decoy_peptides, cache_psm_index)
      else
        nil
      end
    end


    def proteins(cache_protein_byteoffsets=true)
      Mascot::DAT::Proteins.new(self.dat_file, self.idx[:proteins], cache_protein_byteoffsets)
    end

    private
    def parse_index
      idxfn = @dat_file.path + ".idx"
      if File.exists?( idxfn)
        idxf = File.open(idxfn)
        @idx = ::Marshal.load(idxf.read)
        @boundary = @idx[:boundary]
        @boundary_string = @idx[:boundary_string]
        idxf.close
      else
        create_index()
      end
    end

    def create_index
      # grep the boundary positions of the file
      positions = []
      @dat_file.rewind()
      # MIME header line, to parse out boundary
      @dat_file.readline
      @dat_file.readline =~/boundary=(\w+)$/
      @boundary_string = "--#{$1}"
      @boundary = /#{@boundary_string}/
      @idx[:boundary] = @boundary
      @idx[:boundary_string] = @boundary_string
      @dat_file.grep(@boundary) do |l|
        break if @dat_file.eof?
        section_position = @dat_file.pos - l.length
        @dat_file.readline =~ /name="(.+)"/
        @idx[$1.to_sym] = section_position
      end

      if @cache_index
        idxfile = File.open(@dat_file.path + ".idx", 'wb')
        idxfile.write(::Marshal.dump(@idx))
        idxfile.close()
      end
      @dat_file.rewind
    end


  end
end
