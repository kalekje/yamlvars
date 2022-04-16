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

YAMLvars.yaml = require'markdown-tinyyaml' -- note: YAMLvars.sty will have checked existence of this already

local pl = _G['penlight'] or _G['pl'] -- penlight for this namespace is pl
if (__PL_EXTRAS__ == nil) or  (__PENLIGHT__ == nil) then
    tex.sprint('\\PackageError{yamlvars}{penlight package with extras (or extrasnoglobals) option must be loaded before this package}{}')
end

YAMLvars.xfm = {}
YAMLvars.prc = {}
YAMLvars.dec = {} -- table of declare function

YAMLvars.varsvals = {}
YAMLvars.varspecs = {}
YAMLvars.varslowcase = pl.List()

YAMLvars.xfmDefault = {}
YAMLvars.prcDefault = 'gdef'
YAMLvars.dftDefault = nil

YAMLvars.allowUndeclared = false
YAMLvars.overwritedefs = false
YAMLvars.lowvasevarall = false

YAMLvars.valTemp = ''
YAMLvars.varTemp = ''

YAMLvars.tabmidrule = 'hline'

YAMLvars.debug = false




function YAMLvars.debugtalk(s, ss)
    if YAMLvars.debug then
        pl.tex.help_wrt(s, ss)
    end
end

function YAMLvars.pkgerr(m)
    pl.tex.pkgerror('yamlvars', m, '', true)
end




-- todo need distinction beyyween table and penlight list ???
    --val = pl.array2d.map_slice1(_1..'\\\\', val, 1,-2)
    --return val:join('')
    --return pl.tablex.reduce(_1.._2, val, '')

function YAMLvars.xfm.markdown(var, val)
     --return '\\begin{markdown} '..val..'\n \\end{markdown}'
     pl.tex.help_wrt(val, md)
     return [[begin markdown ..val..

     par end markdown]]
end




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
     return pl.array2d.map_slice2(_1..'\\\\\\'.. YAMLvars.tabmidrule..' ', val, 1,-1,-2,-1)
end

function YAMLvars.xfm.arr2tabular(var, val)
     return pl.array2d.toTeX(val)..'\\\\'
end

function YAMLvars.xfm.list2items(var, val)
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

function YAMLvars.xfm.list2nl(var, val)
    if type(val) == 'string' then
        return val
    end
    return pl.List(val):join('\\\\ ')
end

function YAMLvars.xfm.list2and(var, val) -- for doc vars like author, publisher
    if type(val) == 'string' then
        return val
    end
    return pl.List(val):join('\\and ')
end


function YAMLvars.xfm.lb2nl(var, val) --linebreak in text 2 newline \\
    val, _ = val:gsub('\n','\\\\ ')
    return val
end

function YAMLvars.xfm.lb2newline(var, val) --linebreak in text 2 newline \\
    val, _ = val:gsub('\n','\\newline ')
    return val
end

function YAMLvars.xfm.lb2par(var, val) --linebreak in text 2 new l
    val, _ = val:gsub('\n%s*\n','\\par ')
    return val
end

function YAMLvars.xfm.lowercase(var, val)
    return val:lower()
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
    --token.set_macro(var, val, 'global') -- old way, don't do as it will cause issues if val contains undef'd macros
    pl.tex.defcmd(var, val)
    YAMLvars.debugtalk(var..' = '..val, 'prc gdef')
end

function YAMLvars.prc.yvdef(var, val)
    pl.tex.defmacro('yv--'..var, val)
    YAMLvars.debugtalk('yv--'..var..' = '..val, 'prc yvdef')
end

function YAMLvars.prc.toggle(t, v) -- requires penlight extras
    local s = ''
    if pl.hasval(v) then
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



function YAMLvars.prc.setATvar(var, val) -- set a @var directly: eg \gdef\@title{val}
    pl.tex.defcmdAT('@'..var, val)
end


function YAMLvars.prc.setdocvar(var, val) -- call a document var \var{val} = \title{val}
    -- YAML syntax options
    -- k: v -> \k{v}
    -- k:
    --   v1: v2      -> \k[v2]{v1}
    -- k: [v1, v2]   -> \k[v2]{v1}
    -- k: [v1]       -> \k{v1}
    if type(val) ~= 'table' then
        tex.sprint('\\'..var..'{'..val..'}')
    elseif #val == 0 then  -- assume single k,v passed
        for k,v in pairs(val) do
            tex.sprint('\\'..var..'['..v..']{'..k..'}')
        end
    elseif #val == 1 then
        tex.sprint('\\'..var..'{'..val[1]..'}')
    else
        tex.sprint('\\'..var..'['..val[2]..']{'..val[1]..'}')
    end
end


function YAMLvars.prc.setPDFdata(var, val)
    --update pdf meta data table (via penlight), uses pdfx xmpdata
    -- requires a table input
    for k, v in pairs(val) do
        if type(v) == 'table' then
            v = pl.List(v):join('\\sep ')
        end
        pl.tex.updatePDFtable(k, v, true)
    end
end

-- with hyperref package
function YAMLvars.prc.PDFtitle(var, val)
    tex.print('\\hypersetup{pdftitle={'..val..'}}')
end

function YAMLvars.prc.PDFauthor(var, val)
    tex.print('\\hypersetup{pdfauthor={'..val..'}}')
end

-- --


-- ??
--token.set_macro('yv--'..var, val, 'global') -- todo fix with csname hack?



-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function YAMLvars.makecmd(cs, val) -- provide command via lua
   if token.is_defined(cs) and (not YAMLvars.overwritedefs) then
        YAMLvars.pkgerr('Variable '..cs..' already defined, could not declare')
    else
        pl.tex.defcmd(cs, val)
        --token.set_macro(cs, val, 'global') -- issues if val contains undefined macro
    end
end

function YAMLvars.deccmd(cs, def)
    if def == nil then
        YAMLvars.makecmd(cs, '\\PackageError{YAMLvars}{Variable "'..cs..'" was declared and used but, not set}{}')
    else
        YAMLvars.makecmd(cs, def)
    end
end

-- -- -- -- -- --

local function getYAMLfile(y)
    local f = io.open(y,"r")
    if f ~= nil then
        y = f:read('*a')
        io.close(f)
        return y
    else
        YAMLvars.pkgerr('YAML file "'..y..'" not found')
        return 'YAMLvars: FileNotFound'
    end
end


function YAMLvars.declareYAMLvarsStr(y)
    local t = YAMLvars.yaml.parse(y)
    for var, specs in pairs(t) do
        if pl.hasval(specs['lowcasevar']) or YAMLvars.lowvasevarall then
            var = var:lower()
            YAMLvars.varslowcase:append(var)
        end
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
            YAMLvars.debugtalk(var..' = '..val,'yvdef made (undeclared)')
        else
            YAMLvars.makecmd(var, val)
            YAMLvars.debugtalk(var..' = '..val,'gdef made (undeclared)')
        end
     else
        --tex.print('\\PackageError{YAMLvars}{Variable "'..var..'" set but not declared}{}')
        YAMLvars.pkgerr('Variable "'..var..'" set but not declared')
    end
end

local function sub_lua_var(s, v1, v2)
    return s:gsub('([%A?%-?])('..v1..')([%W?%-?])', '%1'..v2..'%3') -- replace x variables
end

local _YV_invalid_expression = '\1 invalid expression'
local _YV_no_return = '\2 no return val'

local function expr_err(var, val)
    --tex.print('\\PackageError{YAMLvars}{xfm with "= or /" error on var "'..var..'"}{}') -- todo make program stop
    YAMLvars.pkgerr('xfm with "= or /" error on var "'..var..'"}{}') -- todo make program stop
end

local function eval_expr(func, var, val)
    local s, c = func:gsub('^[=/]', {['/'] = '\2', ['='] = 'YAMLvars.valTemp = '}, 1) -- / is run code, = sets val = code
    if c == 0 then
        return _YV_invalid_expression
    else
        --pl.tex.help_wrt(s, var)
        --pl.tex.help_wrt(val, var)
        YAMLvars.valTemp = val
        YAMLvars.varTemp = var
        --pl.tex.help_wrt(s, var)
        s, c = s:gsub('\2', '') -- strip \2 that might have appeared if / was applied
        s = sub_lua_var(' '..s, 'x', 'YAMLvars.valTemp')
        s = sub_lua_var(s, 'v', 'YAMLvars.varTemp')
        --pl.tex.help_wrt(s, var)
        local f, err = pcall(loadstring(s))
        if not f then
            --tex.print('\\PackageError{YAMLvars}{xfm with "= or /" error on var "'..var..'"}{}') --
            YAMLvars.pkgerr('xfm with "= or /" error on var "'..var) --
        end
        if c > 0 then
            expr_err(var)
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
                --tex.print('\\PackageError{YAMLvars}{xfm function "'..func..'" not defined or invalid expression passed on var "'..var..'"}{}')
                YAMLvars.pkgerr('xfm function "'..func..'" not defined or invalid expression passed on var "'..var)
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
        --tex.print('\\PackageError{YAMLvars}{prc function "'..YAMLvars.varspecs[var]['prc']..'" on var "'..var..'" not defined}{}')
        YAMLvars.pkgerr('prc function "'..YAMLvars.varspecs[var]['prc']..'" on var "'..var..'" not defined')
    end
    f(var, val) -- prc the value of the variable
end

function YAMLvars.parseYAMLvarsStr(y)
    YAMLvars.varsvals = YAMLvars.yaml.parse(y)
    for var, val in pairs(YAMLvars.varsvals) do
        if YAMLvars.varslowcase:contains(var:lower()) then
            var = var:lower()
        end
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
    --pl.tex.help_wrt(t)
    return t
 end



YAMLvars.yaml2PDFmetadata = function(ytext) -- parse a YAML file and update the pdfmetadata table
      __PDFmetadata__ = __PDFmetadata__ or {} -- existing metadata
      if ytext ~= nil then
        local pdfmetadata_yaml = YAMLvars.yaml.parse(ytext) -- new metadata
        local t = {}
        for k,v in pairs(pdfmetadata_yaml) do  -- ensure first character is capital letter
            t[k:upfirst()] = v
        end
        __PDFmetadata__ = table.update(__PDFmetadata__, t)
      end
    end







-- graveyard


function YAMLvars.prc.setheader(val, rl)
    local _, count = string.gsub(val, '\\\\', '')
    if count == 0 then
        val = '{\\ }\\\\'..val
    end
    val = '\\setstretch{0.8}'..val
    tex.print('\\'..rl..'ohead{'..val..'}')
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



function YAMLvars.prc.memoTo(var, val)
    for k, v in pairs(v) do
        pl.tex.defcmd('@memoTo', val)
        v = YAMLvars.xfm.list2nl(var, v)
        pl.tex.defcmd('@memoTo', val)
    end
end
function YAMLvars.prc.memoFr(var, val)
    for k, v in pairs(v) do
        pl.tex.defcmd('@memoFr', val)
        v = YAMLvars.xfm.list2nl(var, v)
        pl.tex.defcmd('@memoFrAddr', val)

    end
end
-- produce \Var[val[2]\\val[3].....\val[n]]{val[1]}
--function YAMLvars.prc.setdocvarOpt(var, val)
--       if type(val) ~= 'table' then
--            val = {val}
--        end
--        local s = '\\'..var..'{'..tostring(val[1])..'}'
--        s = s..'['..pl.List(v):map_slice1():join()..']' -- what does this do?
--        tex.print(s)
--end
--
--
--function YAMLvars.prc.setdocvarOpts(var, val)
--        if type(val) ~= 'table' then
--            val = {val}
--        end
--        local s = '\\'..var..'{'..tostring(val[1])..'}'
--        for k, v in pairs(val) do
--            if k > 1 then
--                s = s..'['..tostring(v)..']'
--            end
--        end
--        tex.print(s)
--end

return YAMLvars









     --token.set_macro('@memoFr', k, 'global')
        --token.set_macro('@memoFrAddr', v, 'global')
        --token.set_macro('@memoTo', k, 'global')
        --token.set_macro('@memoToAddr', v, 'global')
        --help_wrt(var,val)
        --        token.set_macro('@'..var, val, 'global')

--function YAMLvars.prc.title(var, val)
--        YAMLvars.prc.setdocvar('title', val)
--end
--
--
--function YAMLvars.prc.author(var, val)
--        YAMLvars.prc.setdocvar('author', val)
--end
--
--function YAMLvars.prc.date(var, val)
--        YAMLvars.prc.setdocvar('date', val)
--end


  --clean = clean or true
    --if clean then -- clean first part of yaml string
    --    y = clean_tex_spaces(y)
    --end
--local function clean_tex_spaces(s)
--    pl.tex.help_wrt(s)
--    if s:sub(1,2) == '%s' then
--        s, _ = s:gsub('%s+','',1)
--    end
--    s, _ = s:gsub('\\par ','\n\n')
--    return s
--end

