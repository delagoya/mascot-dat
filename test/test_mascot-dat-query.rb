require 'test_mascot-dat-helper'

class TestMascotDatQuery < TestMascotDatHelper
  def setup
    super
    @query = @dat.query(23)
  end
  def test_name
    assert_equal("query23", @query.name)
  end
  def test_title
    assert_equal("281.832701459371_513",@query.title)
  end
  def test_rtinseconds
    assert_equal(513.0, @query.rtinseconds)
  end
  def test_index
    assert_equal(30,@query.index)
  end
  def test_charge
    assert_equal("3+",@query.charge)
  end
  def test_mass_min
    assert_equal(59.044502, @query.mass_min)
  end
  def test_mass_max
    assert_equal(730.399487,@query.mass_max)
  end
  def test_int_min
    assert_equal(1.951e+05, @query.int_min)
  end
  def test_int_max
    assert_equal(1.951e+05, @query.int_max)
  end
  def test_num_vals
    assert_equal(33,@query.num_vals)
  end
  def test_num_used1
    assert_equal(-1, @query.num_used1)
  end

  def test_peaks
    expected_peaks = Marshal.load(File.read("test/fixtures/query23_peaks.dmp"))
    assert_equal(expected_peaks,@query.peaks)
  end

  def test_mz_array
    mz_expected = [59.044502, 76.396653, 88.063115, 92.727062, 111.734216,
      114.091341, 122.082957, 138.586954, 160.757021, 167.097686, 171.105762,
      175.118953, 182.620797, 190.112916, 206.443325, 223.795476, 227.175405,
      240.631893, 244.138013, 256.155004, 276.166632, 284.665736, 309.16135,
      333.188096, 335.189576, 364.234317, 365.703382, 480.256511, 511.302732,
      568.324196, 617.315423, 669.371875, 730.399487]
      assert_equal(mz_expected,@query.mz)
  end

  def test_intensity_array
    intensity_expected = [195100.0, 195100.0, 195100.0, 195100.0, 195100.0,
      195100.0, 195100.0, 195100.0, 195100.0, 195100.0, 195100.0, 195100.0,
      195100.0, 195100.0, 195100.0, 195100.0, 195100.0, 195100.0, 195100.0,
      195100.0, 195100.0, 195100.0, 195100.0, 195100.0, 195100.0, 195100.0,
      195100.0, 195100.0, 195100.0, 195100.0, 195100.0, 195100.0, 195100.0]
      assert_equal(intensity_expected,@query.intensity)
  end
end