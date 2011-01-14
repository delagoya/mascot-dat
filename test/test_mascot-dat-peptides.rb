require 'test_mascot-dat-helper'
require 'mascot/dat/peptides'

class TestMascotDatPeptides < TestMascotDatHelper

  def setup
    super
    @peptides = @dat.peptides
  end

  def test_peptides
    assert_kind_of(Mascot::DAT::Peptides, @peptides)
  end

  def test_peptides_psmindex_not_empty
    refute_empty(@peptides.psmidx)
  end
  def test_peptides_psmindex_is_empty
    peptides = @dat.peptides(false)
    assert_empty(peptides.psmidx)
  end

  def test_peptides_first_psm_position
    # position for q1_p1 PSM from test/fixtures/example.dat
    expected_position = 1843073
    assert_equal(expected_position, @peptides.psmidx[1][1])
  end

  def test_peptides_psm_q11_p2_position
    # position for q1_p1 PSM from test/fixtures/example.dat
    expected_position =1871224
    assert_equal(expected_position, @peptides.psmidx[11][2])
  end

  def test_peptides_parse_first_psm
    pass
  end
end
