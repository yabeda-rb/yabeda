# frozen_string_literal: true

RSpec.describe Yabeda::DSL::ClassMethods do
  after do
    if Yabeda.instance_variable_defined?(:@groups)
      Yabeda.instance_variable_get(:@groups).keys.each do |group|
        Yabeda.singleton_class.send(:remove_method, group)
      end
      Yabeda.remove_instance_variable(:@groups)
    end

    if Yabeda.instance_variable_defined?(:@metrics)
      Yabeda.instance_variable_get(:@metrics).keys.each do |metric|
        Yabeda.singleton_class.send(:remove_method, metric)
      end
      Yabeda.remove_instance_variable(:@metrics)
    end
  end

  describe ".group" do
    context "without block" do
      before do
        Yabeda.configure do
          group :group1
          gauge :test_gauge

          group :group2
          histogram :test_histogram, buckets: [1, 10, 100]
        end
      end

      it "defines metric method on the root object" do
        expect(Yabeda.group1_test_gauge).to be_a(Yabeda::Gauge)
        expect(Yabeda.group2_test_histogram).to be_a(Yabeda::Histogram)
      end

      it "defines group methods on the root object" do
        expect(Yabeda.group1).to be_a(Yabeda::Group)
        expect(Yabeda.group2).to be_a(Yabeda::Group)
      end

      it "defines methods on the group objects" do
        expect(Yabeda.group1.test_gauge).to be_a(Yabeda::Gauge)
        expect(Yabeda.group2.test_histogram).to be_a(Yabeda::Histogram)
      end
    end

    context "with block" do
      before do
        Yabeda.configure do
          group(:group1) { gauge(:test_gauge) }
          histogram(:test_histogram, buckets: [1, 10, 100])
        end
      end

      it "defines metric method on the root object" do
        expect(Yabeda.group1_test_gauge).to be_a(Yabeda::Gauge)
      end

      it "not attaches metric to a previous group" do
        expect(Yabeda.test_histogram).to be_a(Yabeda::Histogram)
      end

      it "defines group methods on the root object" do
        expect(Yabeda.group1).to be_a(Yabeda::Group)
      end

      it "defines methods on the group objects" do
        expect(Yabeda.group1.test_gauge).to be_a(Yabeda::Gauge)
      end
    end
  end

  describe ".counter" do
    subject { Yabeda.test_counter }

    context "when properly configured" do
      before do
        Yabeda.configure { counter(:test_counter) }
      end

      it("defines method on root object") { is_expected.to be_a(Yabeda::Counter) }
    end
  end

  describe ".gauge" do
    subject { Yabeda.test_gauge }

    context "when properly configured" do
      before do
        Yabeda.configure { gauge(:test_gauge) }
      end

      it("defines method on root object") { is_expected.to be_a(Yabeda::Gauge) }
    end
  end

  describe ".histogram" do
    subject { Yabeda.test_histogram }

    context "when properly configured" do
      before do
        Yabeda.configure { histogram(:test_histogram, buckets: [1, 10, 100]) }
      end

      it("defines method on root object") { is_expected.to be_a(Yabeda::Histogram) }
    end
  end

  describe ".general_tag" do
    subject { Yabeda.general_tags }

    context 'when general tag configured' do
      before do
        Yabeda.configure { general_tag :environment, 'test' }
      end

      it { is_expected.to eq({ environment: 'test' }) }
    end
  end
end
