require 'parslet'

class Parser < Parslet::Parser
  rule(:lparen)     { str('(') >> space? }
  rule(:rparen)     { str(')') >> space? }
  rule(:comma)      { str(',') >> space? }

  rule(:space)      { match('\s').repeat(1) }
  rule(:space?)     { space.maybe }

  rule(:newline)    { str("\n") >> str("\r").maybe }

  # Values
  rule(:integer)    { str('-').maybe >> match('[0-9]').repeat(1).as(:int) >> space? }
  rule(:float)      { str('-').maybe >> (match('[0-9]').repeat(1) >> str('.') >> match('[0-9]').repeat(1)).as(:float) >> space? }
  rule(:boolean)    { (str('true') | str('false')).as(:bool) >> space? }
  rule(:string)     { str('"') >> (str('"').absent? >> any).repeat.as(:str) >> str('"') >> space? }
  rule(:identifier) { match['a-z_'].repeat(1).as(:id) }

  # Lists
  rule(:arglist)    { (expression >> (comma >> expression).repeat).maybe }
  rule(:paramlist)  { (identifier >> (comma >> identifier).repeat).maybe }
  rule(:explist)    { space? >> expression.repeat >> space? }

  # Operators
  rule(:add_ops)    { match('[+-]') | str('isnt') | str('is') | str('<=') | str('>=') | str('<') | str('>') | str('or') | str('and') }
  rule(:mul_ops)    { match('[*/]') }

  # Expressions
  rule(:par)        { lparen >> expression.as(:prio) >> rparen }
  rule(:neg)        { str('not') >> space? >> expression.as(:neg) >> space? }
  rule(:add)        { mul.as(:left) >> (add_ops.as(:op) >> space? >> mul.as(:right)).repeat.as(:binary_operation) }
  rule(:mul)        { val.as(:left) >> (mul_ops.as(:op) >> space? >> val.as(:right)).repeat.as(:binary_operation) }
  rule(:ass)        { identifier.as(:left) >> space? >> str('=').as(:ass) >> space? >> expression.as(:right) }
  rule(:fuc)        { identifier.as(:funcall) >> lparen >> arglist.as(:arglist) >> rparen }
  rule(:fud)        { lparen >> paramlist.as(:paramlist) >> rparen >> str('{') >> space? >> explist.as(:explist) >> space? >> str('}') >> space? }
  rule(:ife)        {
                      str('if').as(:if) >> space? >> add.as(:condition) >> space? >> str('{') >> space? >> explist.as(:ifexplist) >> space? >> str('}') >> space? >>
                      (str('else').as(:else) >> space? >> str('{') >> space? >> explist.as(:elseexplist) >> space? >> str('}') >> space?).maybe
                    }
  rule(:whi)        { str('while').as(:while) >> space? >> add.as(:condition) >> space? >> str('{') >> space? >> explist.as(:explist) >> space? >> str('}') >> space? }
  rule(:val)        { par | neg | fuc | float | integer | boolean | string | (identifier >> space?) }
  rule(:com)        { str('#') >> space? >> (newline.absent? >> any).repeat >> space? }

  rule(:expression) { com | fud | whi | ife | ass | add | val }
  root :explist
end
