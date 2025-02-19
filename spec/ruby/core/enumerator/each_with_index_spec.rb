require_relative '../../spec_helper'
require_relative 'shared/with_index'
require_relative '../enumerable/shared/enumeratorized'

describe "Enumerator#each_with_index" do
  it_behaves_like :enum_with_index, :each_with_index
  it_behaves_like :enumeratorized_with_origin_size, :each_with_index, [1,2,3].select

  it "returns a new Enumerator when no block is given" do
    enum1 = [1,2,3].select
    enum2 = enum1.each_with_index
    enum2.should be_an_instance_of(Enumerator)
    enum1.should_not == enum2
  end

  it "raises an ArgumentError if passed extra arguments" do
    -> do
      [1].to_enum.each_with_index(:glark)
    end.should raise_error(ArgumentError)
  end

  it "passes on the given block's return value" do
    arr = [1,2,3]
    arr.delete_if.each_with_index { |a,b| false }
    arr.should == [1,2,3]
  end

  it "returns the iterator's return value" do
    [1,2,3].select.each_with_index { |a,b| false }.should == []
    [1,2,3].select.each_with_index { |a,b| true }.should == [1,2,3]
  end

  it "returns the correct value if chained with itself" do
    [:a].each_with_index.each_with_index.to_a.should == [[[:a,0],0]]
  end
end
