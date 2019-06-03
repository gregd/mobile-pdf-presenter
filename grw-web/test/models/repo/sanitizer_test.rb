require 'test_helper'

class Repo::SanitizerTest < ActiveSupport::TestCase

  test "file name" do
    s = Repo::Sanitizer.new
    assert_equal "Foo bar.pdf", s.filename("Foo $* bar <> .. /\\ .pdf")
    assert_equal "Ważność Ćmy.pdf", s.filename("Ważność Ćmy .pdf")
    assert_equal "binrm -fr", s.filename("../../../bin/rm -fr")
    assert_equal "foobar", s.filename("foo/bar")
    assert_equal "hidden", s.filename(".hidden")
    assert_equal "hidden", s.filename("..hidden")
    assert_equal "_foo", s.filename("__foo")
    assert_equal "__foo", s.filename("__foo", true)
    assert_equal "Foo - bar.mp4", s.filename("Foo - bar.mp4")
    assert_equal "a" * 127, s.filename("a" * 130)
    assert_equal "", s.filename("")
    assert_nil s.filename(nil)
  end

  test "path" do
    s = Repo::Sanitizer.new
    assert_equal "/foo/bar.txt", s.path("  / foo/bar.txt ")
    assert_equal "foo/bar/ala.txt", s.path("foo/bar/ala.txt")
    assert_equal "/foo/bar/ala.txt", s.path("/foo//bar/ala.txt")
    assert_equal "/bin/rm", s.path("../../../bin/rm")
    assert_equal "/bash", s.path("/$/*/bash")
    assert_equal "/foo/bar", s.path("/foo&/bar*")
    assert_nil s.path(".")
    assert_nil s.path("")
    assert_nil s.path(nil)
  end

  test "git rev" do
    s = Repo::Sanitizer.new
    assert_nil s.git_rev(nil)
    assert_nil s.git_rev("")
    assert_nil s.git_rev("a1" * 50)
    assert_equal nil, s.git_rev("0bd.3e659ddeb383b1ce701a2fc8ea48e0b2dd09")
    assert_equal "0bd53e659ddeb383b1ce701a2fc8ea48e0b2dd09", s.git_rev("0bd53e659ddeb383b1ce701a2fc8ea48e0b2dd09")
    assert_equal "a1d3b02e8c78f000db9e2650d47ed51be012f9ae", s.git_rev("a1d3b02e8c78f000db9e2650d47ed51be012f9ae")
  end

end