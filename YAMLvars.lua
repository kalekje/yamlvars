--% Kale Ewasiuk (kalekje@gmail.com)
--% 2021-09-24
--%
--% Copyright (C) 2021 Kale Ewasiuk
--%
--% Permission is hereby granted, free of charge, to any person obtaining a copy
--% of this software and associated documentation files (the "Software"), to deal
--% in the Software without restriction, including without limitation the rights
--% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
--% copies of the Software, and to permit persons to whom the Software is
--% furnished to do so, subject to the following conditions:
--%
--% The above copyright notice and this permission notice shall be included in
--% all copies or substantial portions of the Software.
--%
--% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF
--% ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED
--% TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
--% PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT
--% SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR
--% ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
--% ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
--% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE
--% OR OTHER DEALINGS IN THE SOFTWARE.


-- tinyyaml license
--MIT License
--
--Copyright (c) 2017 peposso
--
--Permission is hereby granted, free of charge, to any person obtaining a copy
--of this software and associated documentation files (the "Software"), to deal
--in the Software without restriction, including without limitation the rights
--to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
--copies of the Software, and to permit persons to whom the Software is
--furnished to do so, subject to the following conditions:
--
--The above copyright notice and this permission notice shall be included in all
--copies or substantial portions of the Software.
--
--THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
--IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
--FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
--AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
--LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
--OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
--SOFTWARE.



YAMLvars = {} -- self table
YAMLvars.xfm = {}
YAMLvars.prc = {}

YAMLvars.varsvals = {}
YAMLvars.varspecs = {}

YAMLvars.prcDefault = 'gdef'
YAMLvars.dftDefault = nil
YAMLvars.xfmDefault = {}

YAMLvars.allowUndeclared = false

YAMLvars.valTemp = ''
YAMLvars.varTemp = ''

YAMLvars.tabmidrule = 'hline'

YAMLvars.yaml = require('tinyyaml')


-- xfm functions (transforms) -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
function YAMLvars.xfm.addxspace(var, val)
    return val .. '\\xspace'
end

function YAMLvars.xfm.tab2arr(var, val)
     return pl.array2d.from_table(val)
end

function YAMLvars.xfm.arrsort2ZA(var, val)
    return pl.array2d.sortOP(val, pl.operator.strgt)
end

function YAMLvars.xfm.addrule2arr(var, val)
     return pl.array2d.map_slice2(_1..'\\\\\\'.. YAMLvars.tabmidrule..' ', val, 1,-1,-2,-1) -- todo make gmidrule
end

function YAMLvars.xfm.arr2tabular(var, val)
     return pl.array2d.toTeX(val)..'\\\\'
end


function YAMLvars.xfm.arr2itemize(var, val)
     return pl.List(val):map('\\item '.._1):join(' ')
end


function YAMLvars.xfm.arrsortAZ(var, val)
     return pl.List(val):sort(pl.operator.strlt)
end

function YAMLvars.xfm.arrsortZA(var, val)
     return pl.List(val):sort(pl.operator.strgt)
end

local function complastname(a, b)
    a = a:split(' ')
    b = b:split(' ')
    a = a[#a]
    b = b[#b]
    return a < b
end

function YAMLvars.xfm.arrsortlastnameAZ(var, val)
    val = pl.List(val):sort(complastname)
    return val
end
-- todo need distinction beyyween table and penlight list ???
function YAMLvars.xfm.list2nl(var, val)
    val = pl.array2d.map_slice1(_1..'\\\\', val, 1,-2)
    return val:join('')
    --return pl.tablex.reduce(_1.._2, val, '')
end

function YAMLvars.xfm.lb2nl(var, val)
    val, _ = val:gsub('\n','\\\\ ')
    return val
end

function YAMLvars.xfm.lowercase(var, val)
    return val:lower()
end


function YAMLvars.xfm.markdown(var, val)
     --return '\\begin{markdown} '..val..'\n \\end{markdown}'
     help_wrt(val, md)
     return [[begin markdown ..val..

     par end markdown]]
end



-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --


-- prc functions (processing) -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function YAMLvars.prc.gdef(var, val)
    token.set_macro(var, val, 'global')
end

function YAMLvars.prc.yvdef(var, val)
    token.set_macro('yv--'..var, val, 'global')
end

function YAMLvars.prc.PDFtitle(var, val)
    tex.print('\\hypersetup{pdftitle={'..val..'}}')
    --tex.print('\\setPDFtitle{'..val..'}')
end

function YAMLvars.prc.PDFauthor(var, val)
    tex.print('\\hypersetup{pdfauthor={'..val..'}}')
        --tex.print('\\setPDFauthor{'..val..'}')
end


function YAMLvars.prc.setheader(val, rl)
    local _, count = string.gsub(val, '\\\\', '')
    if count == 0 then
        val = '{\\ }\\\\'..val
    end
    val = '\\setstretch{0.8}'..val
    tex.print('\\'..rl..'ohead{'..val..'}')
end

function YAMLvars.prc.rhead(var, val)
    YAMLvars.prc.setheader(val, 'r')
end

function YAMLvars.prc.lhead(var, val)
    YAMLvars.prc.setheader(val, 'l')
end

function YAMLvars.prc.title(var, val)
        token.set_macro('@title', val, 'global')
end

function YAMLvars.prc.author(var, val)
        token.set_macro('@author', val, 'global')
end

function YAMLvars.prc.date(var, val)
        token.set_macro('@date', val, 'global')
end

-- do this with author, title, company
function YAMLvars.prc.setdocvar(var, val)
        tex.print('\\'..var..'{'..val..'}')
end

function YAMLvars.prc.setdocvarOpts(var, val)
        local s = '\\'..var..'{'..tostring(val[1])..'}'
        for k, v in pairs(val) do
            if k > 1 then
                s = s..'['..tostring(v)..']'
            end
        end
        tex.print(s)
end

function YAMLvars.prc.toggle(t, v) -- requires penlight extras
    if hasval(v) then
        tex.print('\\global\\toggletrue{'..t..'}')
    else
        tex.print('\\global\\togglefalse{'..t..'}')
    end
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --



function YAMLvars.prvcmd(cs, val) -- provide command via lua
   if token.is_defined(cs) then
        tex.print('\\PackageError{YAMLvars}{Variable '..cs..' already defined, could not declare}{}')
    else
        token.set_macro(cs, val, 'global')
    end
end

function YAMLvars.deccmd(cs, def)
    if def == nil then
        YAMLvars.prvcmd(cs, '\\PackageError{YAMLvars}{Variable "'..cs..'" was declared and used but, not set}{}')
    else
        YAMLvars.prvcmd(cs, def)
    end
end


local function getYAMLfile(y)
    local f = io.open(y,"r")
    if f ~= nil then
        y = f:read('*a')
        io.close(f)
        return y
    else
        tex.print('\\PackageError{YAMLvars}{YAML file "'..y..'" not found}{}')
        return 'YAMLvars: FileNotFound'
    end
end



function YAMLvars.declareYAMLvarsStr(y)
    local t = YAMLvars.yaml.parse(y)
    for var, specs in pairs(t) do
        YAMLvars.varspecs[var] = {xfm=YAMLvars.xfrmDefault,prc=YAMLvars.prcDefault,dft=YAMLvars.dftDefault}
        if type(specs) == 'string' then
            specs = {xfm={specs}}
        end
        if specs['xfm'] == nil then specs['xfm'] = {} end
        for s, p in pairs(specs) do
            if s == 'xfm' and type(p) ~= 'table' then p = {p} end
            YAMLvars.varspecs[var][s] = p -- set property of var
        end
        if YAMLvars.varspecs[var]['prc'] == 'gdef' then
            YAMLvars.deccmd(var, YAMLvars.varspecs[var]['dft'])
        elseif YAMLvars.varspecs[var]['prc'] == 'yvdef' then
            YAMLvars.deccmd('yv--'..var, YAMLvars.varspecs[var]['dft'])
        elseif YAMLvars.varspecs[var]['prc'] == 'toggle' then
            tex.print('\\global\\newtoggle{'..var..'}')
            YAMLvars.prc.toggle(var, YAMLvars.varspecs[var]['dft'])
        end
    end
end

function YAMLvars.declareYAMLvarsFile(y)
    YAMLvars.declareYAMLvarsStr(getYAMLfile(y))
end


local  function check_def(var, val)
    if YAMLvars.allowUndeclared then
        if YAMLvars.prcDefault == 'yvdef' then
            YAMLvars.prc.yvdef(var, val)
        else
            YAMLvars.prvcmd(var, val)
        end
     else
        tex.print('\\PackageError{YAMLvars}{Variable "'..var..'" set but not declared}{}')
    end
end

local function sub_lua_var(s, v1, v2)
    return s:gsub('([%A?%-?])('..v1..')([%W?%-?])', '%1'..v2..'%3') -- replace x variables
end

local function eval_expr(func, var, val)
    local s, c = func:gsub('^[=/]', {['/'] = '', ['='] = 'YAMLvars.valTemp = '}, 1) -- / is run code, = sets val = code
    if c == 0 then
        return nil
    else
        --help_wrt(s, var)
        --help_wrt(val, var)
        YAMLvars.valTemp = val
        YAMLvars.varTemp = var
        --help_wrt(s, var)
        s = sub_lua_var(' '..s, 'x', 'YAMLvars.valTemp')
        s = sub_lua_var(s, 'v', 'YAMLvars.varTemp')
        --help_wrt(s, var)
        loadstring(s)()
        --help_wrt(val, var)
        return YAMLvars.valTemp
    end
end

local function transform_and_prc(var, val)
    for _, func in pairs(YAMLvars.varspecs[var]['xfm']) do --apply cleaning functions
        local f = YAMLvars.xfm[func]
        if f == nil then
            local val2 =  eval_expr(func, var, val)
            if val2 == nil then
                tex.print('\\PackageWarning{YAMLvars}{xfm function "'..func..'" not defined, skipping}{}')
            else
                val = val2
            end
        else
            val = f(var, val)
        end
    end
    f = YAMLvars.prc[YAMLvars.varspecs[var]['prc']]
    if f == nil then
        tex.print('\\PackageError{YAMLvars}{prc function "'..YAMLvars.varspecs[var]['prc']..'" not defined}{}')
    end
    f(var, val) -- prc the value of the variable
end

function YAMLvars.parseYAMLvarsStr(y)
    YAMLvars.varsvals = YAMLvars.yaml.parse(y)
    for var, val in pairs(YAMLvars.varsvals) do
        if YAMLvars.varspecs[var] == nil then
            check_def(var, val)
        else
            transform_and_prc(var, val)
        end
    end
end

function YAMLvars.parseYAMLvarsFile(y)
    YAMLvars.parseYAMLvarsStr(getYAMLfile(y))
end



function YAMLvars.print_varspecs()
    local pretty = require('pl.pretty')
    texio.write_nl('VVVVVV Var specifications:')
    texio.write_nl(pretty.write(YAMLvars.varspecs))
end



-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- https://tex.stackexchange.com/questions/38150/in-lualatex-how-do-i-pass-the-content-of-an-environment-to-lua-verbatim
recordedbuf = ""
function readbuf(buf)
    i,j = string.find(buf, '\\end{%w+}')
     if i==nil then -- if not ending an environment
        recordedbuf = recordedbuf .. buf .. "\n"
        return ""
    else
        return nil
    end
end

function startrecording()
    recordedbuf = ""
    luatexbase.add_to_callback('process_input_buffer', readbuf, 'readbuf')
end

function stoprecording()
    luatexbase.remove_from_callback('process_input_buffer', 'readbuf')
    recordedbuf = recordedbuf:gsub("\\end{%w+}\n","")
end



function YAMLvars.doYAMLfiles(t)
    if #t == 2 then
        YAMLvars.declareYAMLvarsFile(t[1])
        YAMLvars.parseYAMLvarsFile(t[2])
    elseif #t == 1 then
        YAMLvars.parseYAMLvarsFile(t[1])
    else
        tex.print('\\PackageWarning{YAMLvars}{No .yaml files found in CLI args"}{}')
    end
end

function YAMLvars.getYAMLcli()
    local t = {}
    if arg then
      for i,v in pairs(arg) do
          if v:find('.*%.yaml$') then
              t[#t+1] = v
          end
      end
    end
    --help_wrt(t)
    return t
 end


return YAMLvars



  --clean = clean or true
    --if clean then -- clean first part of yaml string
    --    y = clean_tex_spaces(y)
    --end
--local function clean_tex_spaces(s)
--    help_wrt(s)
--    if s:sub(1,2) == '%s' then
--        s, _ = s:gsub('%s+','',1)
--    end
--    s, _ = s:gsub('\\par ','\n\n')
--    return s
--end