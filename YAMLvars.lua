--% Kale Ewasiuk (kalekje@gmail.com)
--% +REVDATE+
--% Copyright (C) 2021-2022 Kale Ewasiuk
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
YAMLvars.dec = {} -- table of declare function

YAMLvars.varsvals = {}
YAMLvars.varspecs = {}

YAMLvars.prcDefault = 'gdef'
YAMLvars.dftDefault = nil
YAMLvars.xfmDefault = {}

YAMLvars.allowUndeclared = false
YAMLvars.overwritedefs = false

YAMLvars.valTemp = ''
YAMLvars.varTemp = ''

YAMLvars.tabmidrule = 'hline'

YAMLvars.debug = false

YAMLvars.yaml = require'markdown-tinyyaml' -- note: YAMLvars.sty will have checked existence of this already
local pl = _G['penlight'] or _G['pl'] -- penlight for this namespace is pl


function YAMLvars.debugtalk(s, ss)
    if YAMLvars.debug then
        help_wrt(s, ss)
    end
end


-- xfm functions (transforms) -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
function YAMLvars.xfm.addxspace(var, val)
    return val .. '\\xspace{}'
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


function YAMLvars.xfm.list2items(var, val) -- todo should be list2item
     return pl.List(val):map('\\item '.._1):join(' ')
end
YAMLvars.xfm.arr2itemize = YAMLvars.xfm.list2items

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
    return pl.tablex.join(val,'\\\\ ')
end

    --val = pl.array2d.map_slice1(_1..'\\\\', val, 1,-2)
    --return val:join('')
    --return pl.tablex.reduce(_1.._2, val, '')


function YAMLvars.xfm.lb2nl(var, val) --linebreak in text 2 new line
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



-- dec laration functions, -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function YAMLvars.dec.gdef(var, dft)
            YAMLvars.deccmd(var, dft)
end

function YAMLvars.dec.yvdef(var, dft)
        YAMLvars.deccmd('yv--'..var, dft)
end

function YAMLvars.dec.toggle(var, dft)
        tex.print('\\global\\newtoggle{'..var..'}')
        YAMLvars.prc.toggle(var, dft)
end

function YAMLvars.dec.length(var, dft)
        tex.print('\\global\\newlength{\\'..var..'}')
        YAMLvars.prc.length(var, dft)
end



-- prc functions (processing) -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function YAMLvars.prc.gdef(var, val)
    token.set_macro(var, val, 'global')
    YAMLvars.debugtalk(var..' = '..val, 'prc gdef')
end

function YAMLvars.prc.yvdef(var, val)
    token.set_macro('yv--'..var, val, 'global')
    YAMLvars.debugtalk('yv--'..var..' = '..val, 'prc yvdef')
end

function YAMLvars.prc.toggle(t, v) -- requires penlight extras
    local s = ''
    if hasval(v) then
        s = '\\global\\toggletrue{'..t..'}'
    else
        s = '\\global\\togglefalse{'..t..'}'
    end
    tex.print(s)
    YAMLvars.debugtalk(s, 'prc toggle')
end

function YAMLvars.prc.length(t, v)
    v = v or '0pt'
    local s = '\\global\\setlength{\\global\\'..t..'}{'..v..'}'
    tex.print(s)
    YAMLvars.debugtalk(s, 'prc length')
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



-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --



function YAMLvars.prvcmd(cs, val) -- provide command via lua
   if token.is_defined(cs) and (not YAMLvars.overwritedefs) then
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
        YAMLvars.varspecs[var] = {xfm=YAMLvars.xfmDefault,prc=YAMLvars.prcDefault,dft=YAMLvars.dftDefault}
        if type(specs) == 'string' then
            specs = {xfm={specs}}
        end
        if specs['xfm'] == nil then specs['xfm'] = {} end
        for s, p in pairs(specs) do
            if s == 'xfm' and type(p) ~= 'table' then p = {p} end
            YAMLvars.varspecs[var][s] = p -- set property of var
        end
        if YAMLvars.dec[YAMLvars.varspecs[var].prc] ~= nil then
            YAMLvars.dec[YAMLvars.varspecs[var].prc](var, YAMLvars.varspecs[var].dft)
        --else -- actually don't a dec function for all
        --    -- -- -- tex.print('\\PackageError{YAMLvars}{Declaration function for '..YAMLvarspecs[var].prc..'not found}{}')
        end
    end
    YAMLvars.debugtalk(YAMLvars.varspecs, 'declared YAML vars, varspecs')
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

local _YV_invalid_expression = '\1 invalid expression'
local _YV_no_return = '\2 no return val'
local function eval_expr(func, var, val)
    local s, c = func:gsub('^[=/]', {['/'] = '\2', ['='] = 'YAMLvars.valTemp = '}, 1) -- / is run code, = sets val = code
    if c == 0 then
        return _YV_invalid_expression
    else
        --help_wrt(s, var)
        --help_wrt(val, var)
        YAMLvars.valTemp = val
        YAMLvars.varTemp = var
        --help_wrt(s, var)
        s, c = s:gsub('\2', '') -- strip \2 that might have appeared if / was applied
        s = sub_lua_var(' '..s, 'x', 'YAMLvars.valTemp')
        s = sub_lua_var(s, 'v', 'YAMLvars.varTemp')
        --help_wrt(s, var)
        local f, err = pcall(loadstring(s))
        if not f then
            tex.print('\\PackageError{YAMLvars}{xfm with "= or /" error on var "'..var..'"}{}') --
        end
        if c > 0 then
            return _YV_no_return
        end
        return YAMLvars.valTemp
    end
end

local function transform_and_prc(var, val)
    for _, func in pairs(YAMLvars.varspecs[var]['xfm']) do --apply cleaning functions
        local f = YAMLvars.xfm[func]
        if f == nil then
            local val2 =  eval_expr(func, var, val)
            if val2 == _YV_invalid_expression then
                tex.print('\\PackageError{YAMLvars}{xfm function "'..func..'" not defined or invalid expression passed on var "'..var..'"}{}')
            elseif val == _YV_no_return then
            else
                val = val2
            end
        else
            val = f(var, val)
        end
    end
    f = YAMLvars.prc[YAMLvars.varspecs[var]['prc']]
    if f == nil then
        tex.print('\\PackageError{YAMLvars}{prc function "'..YAMLvars.varspecs[var]['prc']..'" on var "'..var..'" not defined}{}')
    end
    f(var, val) -- prc the value of the variable
end

function YAMLvars.parseYAMLvarsStr(y)
    YAMLvars.varsvals = YAMLvars.yaml.parse(y)
    for var, val in pairs(YAMLvars.varsvals) do
        if YAMLvars.varspecs[var] == nil then
            check_def(var, val) -- if not declared
            -- todo consider free form parse declaring
            -- variable name: {xfm:, dec:, prc:, val: }
            -- definitely doable here
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