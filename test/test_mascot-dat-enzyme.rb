require 'test/unit'
require 'mascot/dat'
require 'mascot/dat/enzyme'

class TestMascotDatEnzyme < Test::Unit::TestCase
  def setup
    @dat = Mascot::DAT.open("test/fixtures/example.dat")
    @enzyme = @dat.enzyme
  end
  def test_enz_create
    assert_kind_of Mascot::DAT::Enzyme, @enzyme
  end
  def test_enz_title
    assert_equal("Trypsin",  @enzyme.title)
  end
  def test_enz_independent
    refute(@enzyme.independent)
  end
  def test_enz_semi_specific
    refute(@enzyme.semi_specific)
  end
  def test_enz_terminals
    assert_equal("C",  @enzyme.terminals[0])
  end
  def test_enz_restrictions
    assert_equal("P",  @enzyme.restrictions[0])
  end
  def test_enz_cleavages
    assert_equal("KR",  @enzyme.cleavages[0])
  end
end