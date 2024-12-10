local function test(str)
	local name = str

	::again::
	if name == 'TestName' then
		goto finish
	else
		name = 'TestName'
		goto again
	end

	::finish::
	return name
end

print(test('Hello World'))

-- output will be: TestName