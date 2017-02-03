def extract_cql_values(_cql)
  attrs = []
  values = []
  case _cql
  when /SELECT|DELETE/
    # SELECT * from table WHERE attr=value AND attr=value
    relations = _cql.match(/WHERE(.*)/i)[1].split(' AND ')
    relations.each do |r|
      vals = r.split('=')
      attrs << vals[0].strip
      values << vals[1].strip
    end
  when /UPDATE/
  when /INSERT/
    # INSERT INTO cassie_schema.versions (id, number, description, executor, executed_at) VALUES (09b5cdce-744d-11e6-935f-79233d2548be, '0.1.2', 'some description', 'eprothro', 1473174464000);
    attrs = _cql.match(/\((.+)\) VALUES/i)[1].split(', ')
    values = _cql.match(/VALUES \((.+)\)/i)[1].split(', ')
  else
    raise 'unsupported cql statement'
  end

  Hash[attrs.zip values]
end