require 'test/unit'
require 'mascot/dat'

class TestMascotDat < Test::Unit::TestCase
  def setup
    @dat = Mascot::Dat.open("test/fixtures/example.dat")
  end

  def test_canary
    assert true, "The canary is dead"
  end

  def test_open_file
    assert_instance_of(Mascot::DAT, @dat)
  end

  def test_dat_boundary
    assert_equal("--gc0p4Jq0M2Yt08jU534c0p", @dat.boundary)
  end

  def test_parameters
  end
  def test_search_databases
  end
  def test_modifications
  end
  def test_header
  end
  def test_get_first_peptide_result
  end
  def test_get_fifth_peptide_result
  end
  def test_get_fifth_decoy_peptide_result
  end
  def test_get_first_protein
  end
  def test_get_tenth_protein
  end
end
