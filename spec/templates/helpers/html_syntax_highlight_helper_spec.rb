require File.dirname(__FILE__) + '/../spec_helper'

describe YARD::Templates::Helpers::HtmlSyntaxHighlightHelper do
  include YARD::Templates::Helpers::HtmlHelper
  include YARD::Templates::Helpers::HtmlSyntaxHighlightHelper
  
  before do
    stub!(:object).and_return(CodeObjects::NamespaceObject.new(:root, :YARD))
  end
  
  describe '#html_syntax_highlight' do
    it "should not highlight source if options[:no_highlight] is set" do
      should_receive(:options).and_return(:no_highlight => true)
      html_syntax_highlight("def x\nend").should == "def x\nend"
    end
    
    it "should highlight source (ruby18)" do
      should_receive(:options).and_return(:no_highlight => false)
      expect = "<span class='def def kw'>def</span><span class='x identifier id'>x</span>
        <span class='string val'>'x'</span><span class='plus op'>+</span>
        <span class='regexp val'>/x/i</span><span class='end end kw'>end</span>"
      result = html_syntax_highlight("def x\n  'x' + /x/i\nend")
      html_equals_string(result, expect)
    end if RUBY18

    it "should highlight source (ruby19)" do
      should_receive(:options).and_return(:no_highlight => false)
      expect = "<span class='kw'>def</span> <span class='id x'>x</span>  
        <span class='tstring'><span class='tstring_beg'>'</span>
        <span class='tstring_content'>x</span><span class='tstring_end'>'</span>
        </span> <span class='op'>+</span> <span class='tstring'>
        <span class='regexp_beg'>/</span><span class='tstring_content'>x</span>
        <span class='regexp_end'>/i</span></span>\n<span class='kw'>end</span>"
      result = html_syntax_highlight("def x\n  'x' + /x/i\nend")
      html_equals_string(result, expect)
    end if RUBY19
    
    it "should return escaped unhighlighted source if a syntax error is found (ruby19)" do
      should_receive(:options).and_return(:no_highlight => false)
      html_syntax_highlight("def &x; ... end").should == "def &amp;x; ... end"
    end if RUBY19
    
    it "should link constants/methods (ruby19)" do
      other = CodeObjects::NamespaceObject.new(:root, :Other)
      should_receive(:run_verifier).with([other]).and_return([other])
      should_receive(:link_object).with(other, "Other").and_return("LINK!")
      result = html_syntax_highlight("def x; Other end")
      html_equals_string(result, "<span class='kw'>def</span> 
        <span class='id x'>x</span><span class='semicolon'>;</span> 
        <span class='const'>LINK!</span> <span class='kw'>end</span>")
    end
  end
end