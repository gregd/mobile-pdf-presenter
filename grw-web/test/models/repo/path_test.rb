require 'test_helper'

class Repo::PathTest < ActiveSupport::TestCase
  REV1 = "10c3886c310bd16ba8c697f88b64273dff373150".freeze
  ACCOUNT_ID = 17

  test "tmp rev" do
    path = Repo::Path.new(account_id: ACCOUNT_ID, repo_name: "main", tmp_rev: REV1)
    root = File.join(Rails.root, "tmp/cache-repo/a#{ACCOUNT_ID}/main")

    assert_equal File.join(root, REV1), path.repo_path
    assert_equal root, path.repo_path_parent
  end

  test "abs and rel path" do
    path = Repo::Path.new(account_id: ACCOUNT_ID, repo_name: "main")
    root = File.join(Rails.root, "data/repos/a#{ACCOUNT_ID}/main")

    assert_equal File.join(root, "foo.txt"), path.abs_path("foo.txt")
    assert_equal "foo.txt", path.rel_path("foo.txt")

    assert_equal File.join(root, "foo/bar.txt"), path.abs_path("foo/bar.txt")
    assert_equal "foo/bar.txt", path.rel_path("foo/bar.txt")

    assert_equal File.join(root, "foo.txt"), path.abs_path("", "foo.txt")
    assert_equal "foo.txt", path.rel_path("", "foo.txt")

    assert_equal File.join(root, "foo.txt"), path.abs_path(nil, "foo.txt")
    assert_equal "foo.txt", path.rel_path(nil, "foo.txt")
  end

end
