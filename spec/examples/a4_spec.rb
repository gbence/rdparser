require File.expand_path('../../support/spec_helper', __FILE__)

describe 'A4::Authorization::Parser' do
  include ParserHelper

  parser do |p|
    p.expression    'expression_u binary expression | expression_u'
    p.expression_u  'unary expression_u | "(" expression ")" | role'
    p.binary        /and|or/
    p.unary         /not/
    p.role          'role_name preposition instance_name | role_name preposition class_name | role_name'
    p.preposition   /of|on|in|at|for|to/
    p.instance_name /:[a-z][a-zA-Z0-9]*/
    p.class_name    /[A-Z][a-zA-Z0-9:]*/
    p.role_name     /[a-z][-_a-zA-Z0-9]*/
  end

  it { should parse("role") }
  it { should parse("role1") }
  it { should parse("role1 and role2") }
  it { should parse("role1 or role2") }
  it { should parse("(role)") }
  it { should parse("(role1) and (role2) or (role3)") }
  it { should parse("(role1 and role2) or (role3)") }
  it { should parse("reader of Klass") }
  it { should parse("reader of :instance") }
  it { should parse("admin or reader of Post or (writer of :instance and guest)") }
  it { should parse("role-with-dashes") }
  it { should parse("role_with_underscores") }

end

