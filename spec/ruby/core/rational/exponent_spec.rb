require_relative "../../spec_helper"

describe "Rational#**" do
  describe "when passed Rational" do
    # Guard against the Mathn library
    guard -> { !defined?(Math.rsqrt) } do
      it "returns Rational(1) if the exponent is Rational(0)" do
        (Rational(0) ** Rational(0)).should eql(Rational(1))
        (Rational(1) ** Rational(0)).should eql(Rational(1))
        (Rational(3, 4) ** Rational(0)).should eql(Rational(1))
        (Rational(-1) ** Rational(0)).should eql(Rational(1))
        (Rational(-3, 4) ** Rational(0)).should eql(Rational(1))
        (Rational(bignum_value) ** Rational(0)).should eql(Rational(1))
        (Rational(-bignum_value) ** Rational(0)).should eql(Rational(1))
      end

      it "returns self raised to the argument as a Rational if the exponent's denominator is 1" do
        (Rational(3, 4) ** Rational(1, 1)).should eql(Rational(3, 4))
        (Rational(3, 4) ** Rational(2, 1)).should eql(Rational(9, 16))
        (Rational(3, 4) ** Rational(-1, 1)).should eql(Rational(4, 3))
        (Rational(3, 4) ** Rational(-2, 1)).should eql(Rational(16, 9))
      end

      it "returns self raised to the argument as a Float if the exponent's denominator is not 1" do
        (Rational(3, 4) ** Rational(4, 3)).should be_close(0.681420222312052, TOLERANCE)
        (Rational(3, 4) ** Rational(-4, 3)).should be_close(1.46752322173095, TOLERANCE)
        (Rational(3, 4) ** Rational(4, -3)).should be_close(1.46752322173095, TOLERANCE)
      end

      it "returns a complex number when self is negative and the passed argument is not 0" do
        (Rational(-3, 4) ** Rational(-4, 3)).should be_close(Complex(-0.7337616108654732, 1.2709123906625817), TOLERANCE)
      end
    end
  end

  describe "when passed Integer" do
    it "returns the Rational value of self raised to the passed argument" do
      (Rational(3, 4) ** 4).should == Rational(81, 256)
      (Rational(3, 4) ** -4).should == Rational(256, 81)
      (Rational(-3, 4) ** -4).should == Rational(256, 81)
      (Rational(3, -4) ** -4).should == Rational(256, 81)

      (Rational(bignum_value, 4) ** 4).should == Rational(452312848583266388373324160190187140051835877600158453279131187530910662656, 1)
      (Rational(3, bignum_value) ** -4).should == Rational(115792089237316195423570985008687907853269984665640564039457584007913129639936, 81)
      (Rational(-bignum_value, 4) ** -4).should == Rational(1, 452312848583266388373324160190187140051835877600158453279131187530910662656)
      (Rational(3, -bignum_value) ** -4).should == Rational(115792089237316195423570985008687907853269984665640564039457584007913129639936, 81)
    end

    # Guard against the Mathn library
    guard -> { !defined?(Math.rsqrt) } do
      it "returns Rational(1, 1) when the passed argument is 0" do
        (Rational(3, 4) ** 0).should eql(Rational(1, 1))
        (Rational(-3, 4) ** 0).should eql(Rational(1, 1))
        (Rational(3, -4) ** 0).should eql(Rational(1, 1))

        (Rational(bignum_value, 4) ** 0).should eql(Rational(1, 1))
        (Rational(3, -bignum_value) ** 0).should eql(Rational(1, 1))
      end
    end
  end

  describe "when passed Bignum" do
    # #5713
    it "returns Rational(0) when self is Rational(0) and the exponent is positive" do
      (Rational(0) ** bignum_value).should eql(Rational(0))
    end

    it "raises ZeroDivisionError when self is Rational(0) and the exponent is negative" do
      -> { Rational(0) ** -bignum_value }.should raise_error(ZeroDivisionError)
    end

    it "returns Rational(1) when self is Rational(1)" do
      (Rational(1) **  bignum_value).should eql(Rational(1))
      (Rational(1) ** -bignum_value).should eql(Rational(1))
    end

    it "returns Rational(1) when self is Rational(-1) and the exponent is positive and even" do
      (Rational(-1) ** bignum_value(0)).should eql(Rational(1))
      (Rational(-1) ** bignum_value(2)).should eql(Rational(1))
    end

    it "returns Rational(-1) when self is Rational(-1) and the exponent is positive and odd" do
      (Rational(-1) ** bignum_value(1)).should eql(Rational(-1))
      (Rational(-1) ** bignum_value(3)).should eql(Rational(-1))
    end

    ruby_version_is ""..."3.4" do
      it "returns positive Infinity when self is > 1" do
        -> {
          (Rational(2) ** bignum_value).infinite?.should == 1
        }.should complain(/warning: in a\*\*b, b may be too big/)
        -> {
          (Rational(fixnum_max) ** bignum_value).infinite?.should == 1
        }.should complain(/warning: in a\*\*b, b may be too big/)
      end

      it "returns 0.0 when self is > 1 and the exponent is negative" do
        -> {
          (Rational(2) ** -bignum_value).should eql(0.0)
        }.should complain(/warning: in a\*\*b, b may be too big/)
        -> {
          (Rational(fixnum_max) ** -bignum_value).should eql(0.0)
        }.should complain(/warning: in a\*\*b, b may be too big/)
      end
    end

    ruby_version_is "3.4" do
      it "raises an ArgumentError when self is > 1" do
        -> {
          (Rational(2) ** bignum_value)
        }.should raise_error(ArgumentError)
        -> {
          (Rational(fixnum_max) ** bignum_value)
        }.should raise_error(ArgumentError)
      end

      it "raises an ArgumentError when self is > 1 and the exponent is negative" do
        -> {
          (Rational(2) ** -bignum_value)
        }.should raise_error(ArgumentError)
        -> {
          (Rational(fixnum_max) ** -bignum_value)
        }.should raise_error(ArgumentError)
      end

      it "raises an ArgumentError when self is < -1" do
        -> {
          (Rational(-2) ** bignum_value)
        }.should raise_error(ArgumentError)
        -> {
          (Rational(fixnum_min) ** bignum_value)
        }.should raise_error(ArgumentError)
      end

      it "raises an ArgumentError when self is < -1 and the exponent is negative" do
        -> {
          (Rational(-2) ** -bignum_value)
        }.should raise_error(ArgumentError)
        -> {
          (Rational(fixnum_min) ** -bignum_value)
        }.should raise_error(ArgumentError)
      end
    end

    # Fails on linux due to pow() bugs in glibc: http://sources.redhat.com/bugzilla/show_bug.cgi?id=3866
    platform_is_not :linux do
      ruby_version_is ""..."3.4" do
        it "returns positive Infinity when self < -1" do
          -> {
            (Rational(-2) ** bignum_value).infinite?.should == 1
          }.should complain(/warning: in a\*\*b, b may be too big/)
          -> {
            (Rational(-2) ** (bignum_value + 1)).infinite?.should == 1
          }.should complain(/warning: in a\*\*b, b may be too big/)
          -> {
            (Rational(fixnum_min) ** bignum_value).infinite?.should == 1
          }.should complain(/warning: in a\*\*b, b may be too big/)
        end

        it "returns 0.0 when self is < -1 and the exponent is negative" do
          -> {
            (Rational(-2) ** -bignum_value).should eql(0.0)
          }.should complain(/warning: in a\*\*b, b may be too big/)
          -> {
            (Rational(fixnum_min) ** -bignum_value).should eql(0.0)
          }.should complain(/warning: in a\*\*b, b may be too big/)
        end
      end
    end
  end

  describe "when passed Float" do
    it "returns self converted to Float and raised to the passed argument" do
      (Rational(3, 1) ** 3.0).should eql(27.0)
      (Rational(3, 1) ** 1.5).should be_close(5.19615242270663, TOLERANCE)
      (Rational(3, 1) ** -1.5).should be_close(0.192450089729875, TOLERANCE)
    end

    it "returns a complex number if self is negative and the passed argument is not 0" do
      (Rational(-3, 2) ** 1.5).should be_close(Complex(0.0, -1.8371173070873836), TOLERANCE)
      (Rational(3, -2) ** 1.5).should be_close(Complex(0.0, -1.8371173070873836), TOLERANCE)
      (Rational(3, -2) ** -1.5).should be_close(Complex(0.0, 0.5443310539518174), TOLERANCE)
    end

    it "returns Complex(1.0) when the passed argument is 0.0" do
      (Rational(3, 4) ** 0.0).should == Complex(1.0)
      (Rational(-3, 4) ** 0.0).should == Complex(1.0)
      (Rational(-3, 4) ** 0.0).should == Complex(1.0)
    end
  end

  it "calls #coerce on the passed argument with self" do
    rational = Rational(3, 4)
    obj      = mock("Object")
    obj.should_receive(:coerce).with(rational).and_return([1, 2])

    rational ** obj
  end

  it "calls #** on the coerced Rational with the coerced Object" do
    rational = Rational(3, 4)

    coerced_rational = mock("Coerced Rational")
    coerced_rational.should_receive(:**).and_return(:result)

    coerced_obj = mock("Coerced Object")

    obj = mock("Object")
    obj.should_receive(:coerce).and_return([coerced_rational, coerced_obj])

    (rational ** obj).should == :result
  end

  it "raises ZeroDivisionError for Rational(0, 1) passed a negative Integer" do
    [-1, -4, -9999].each do |exponent|
      -> { Rational(0, 1) ** exponent }.should raise_error(ZeroDivisionError, "divided by 0")
    end
  end

  it "raises ZeroDivisionError for Rational(0, 1) passed a negative Rational with denominator 1" do
    [Rational(-1, 1), Rational(-3, 1)].each do |exponent|
      -> { Rational(0, 1) ** exponent }.should raise_error(ZeroDivisionError, "divided by 0")
    end
  end

  # #7513
  it "raises ZeroDivisionError for Rational(0, 1) passed a negative Rational" do
    -> { Rational(0, 1) ** Rational(-3, 2) }.should raise_error(ZeroDivisionError, "divided by 0")
  end

  it "returns Infinity for Rational(0, 1) passed a negative Float" do
    [-1.0, -3.0, -3.14].each do |exponent|
      (Rational(0, 1) ** exponent).infinite?.should == 1
    end
  end
end
