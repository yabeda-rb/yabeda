# frozen_string_literal: true

RSpec.describe Yabeda::Group do
  let(:name) { nil }
  let(:group) { described_class.new(name) }

  before { Yabeda.groups[name] = group }

  describe "default tags" do
    context "when on the top level group" do
      it "is an empty by default" do
        expect(group.default_tags).to be_empty
      end
    end

    context "when within a named group" do
      let(:name) { :group1 }

      it "includes top level default_tags" do
        Yabeda.default_tag :tag, "default"
        expect(group.default_tags).to eq(tag: "default")
      end

      it "overrides top level default_tags" do
        Yabeda.default_tag :tag, "default"
        group.default_tag :tag, "overridden"
        expect(Yabeda.groups[nil].default_tags).to eq(tag: "default")
        expect(group.default_tags).to eq(tag: "overridden")
      end
    end
  end

  describe "only" do
    it "appends to the only list" do
      expect(group.only).to be_nil

      group.only :metric1
      expect(group.only).to eq(%i[metric1])

      group.only :metric2
      expect(group.only).to eq(%i[metric1 metric2])
    end
  end

  describe "except" do
    it "appends to the except list" do
      expect(group.except).to be_nil
      group.except :metric1

      expect(group.except).to eq(%i[metric1])
      group.except :metric2

      expect(group.except).to eq(%i[metric1 metric2])
    end
  end
end
