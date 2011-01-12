require 'test/unit'
require 'mascot/dat'

class TestMascotDat < Test::Unit::TestCase
  def setup
    @dat = Mascot::DAT.open("test/fixtures/example.dat")
  end

  def test_canary
    assert true, "The canary is dead"
  end

  def test_open_file
    assert_instance_of(Mascot::DAT, @dat)
  end

  def test_dat_boundary
    assert_equal(Regexp.new("--gc0p4Jq0M2Yt08jU534c0p"), @dat.boundary)
  end

  def test_dat_byteoffset_index_is_created
    File.unlink(@dat.dat_file.path + ".idx") if File.exists?(@dat.dat_file.path + ".idx")
    @dat = Mascot::DAT.open("test/fixtures/example.dat")
    assert(File.exists?(@dat.dat_file.path + ".idx"))
  end

  def test_dat_byteoffset_index_is_not_created
    File.unlink(@dat.dat_file.path + ".idx") if File.exists?(@dat.dat_file.path + ".idx")
    @dat = Mascot::DAT.open("test/fixtures/example.dat",false)
    refute(File.exists?(@dat.dat_file.path + ".idx"))
  end

  def test_goto_summary_section
    @dat.goto("summary")
    # first two lines should be boundary and section statement
    expected_text = "--gc0p4Jq0M2Yt08jU534c0p\nContent-Type: application/x-Mascot; name=\"summary\"\n"
    test_text = @dat.dat_file.readline
    test_text += @dat.dat_file.readline
    assert_equal(expected_text, test_text)
  end

  def test_read_section
    expected_section = File.read("test/fixtures/enzyme_section.txt")
    assert_equal(expected_section, @dat.read_section("enzyme"))
    assert_equal(expected_section, @dat.read_section(:enzyme))
  end

end
