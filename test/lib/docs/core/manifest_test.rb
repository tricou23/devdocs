require 'test_helper'
require 'docs'

class ManifestTest < MiniTest::Spec
  let :doc do
    Class.new Docs::Doc
  end

  let :store do
    Docs::NullStore.new
  end

  let :manifest do
    Docs::Manifest.new store, [doc]
  end

  describe "#store" do
    before do
      stub(manifest).as_json
    end

    it "stores a file" do
      mock(store).write.with_any_args
      manifest.store
    end

    describe "the file" do
      it "is named ::FILENAME" do
        mock(store).write Docs::Manifest::FILENAME, anything
        manifest.store
      end

      it "contains the manifest's JSON dump" do
        stub(manifest).to_json { 'json' }
        mock(store).write anything, 'json'
        manifest.store
      end
    end
  end

  describe "#as_json" do
    let :index_path do
      'index_path'
    end

    before do
      stub(doc).index_path { index_path }
    end

    it "returns an array" do
      manifest = Docs::Manifest.new store, []
      assert_instance_of Array, manifest.as_json
    end

    context "when the doc has an index" do
      before do
        stub(store).exist?(index_path) { true }
      end

      it "includes the doc's JSON representation" do
        json = manifest.as_json
        assert_equal 1, json.length
        assert_empty doc.as_json.keys - json.first.keys
      end

      it "adds an :mtime attribute" do
        mtime = Time.now - 1
        stub(store).mtime(index_path) { mtime }
        assert_equal mtime.to_i, manifest.as_json.first[:mtime]
      end
    end

    context "when the doc doesn't have an index" do
      it "doesn't include the doc" do
        stub(store).exist?(index_path) { false }
        assert_empty manifest.as_json
      end
    end
  end

  describe "#to_json" do
    it "returns the JSON string for #as_json" do
      stub(manifest).as_json { { test: 'ok' } }
      assert_equal '{"test":"ok"}', manifest.to_json
    end
  end
end
