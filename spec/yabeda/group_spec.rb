# frozen_string_literal: true

RSpec.describe Yabeda::Group do
  let(:name) { nil }

  let(:group) { described_class.new(name) }

  before do
    Yabeda.groups[nil] = Yabeda::Group.new(nil) if name
    Yabeda.groups[name] = group
  end

  after { Yabeda.reset! }

  describe "default tags" do
    context "on the top level group" do
      it "is an empty by default" do
        expect(group.default_tags).to be_empty
      end
    end

    context "on a named group" do
      let(:name) { :group1 }

      it "includes top level default_tags" do
        Yabeda.groups[nil].default_tag :tag, "default"
        expect(group.default_tags).to eq(tag: "default")
      end

      it "overrides top level default_tags" do
        Yabeda.groups[nil].default_tag :tag, "default"
        group.default_tag :tag, "overridden"
        expect(Yabeda.groups[nil].default_tags).to eq(tag: "default")
        expect(group.default_tags).to eq(tag: "overridden")
      end
    end
  end
end
