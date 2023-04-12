-- you give this the numbers 0 and 1, it will return a string '0:1'.
-- table keys use this format consistently. 
    function posstr(x,y)
    return fmt('%d:%d',x,y)
    end

-- you give this the string '0:1', it will return 0 and 1. 
    function strpos(pos)
    local delim=string.find(pos,':')
    local x=sub(pos,1,delim-1)
    local y=sub(pos,delim+1)
    --important tonumber calls
    --Lua will handle a string+number addition until it doesn't
    return tonumber(x),tonumber(y)
    end

-- palette swapping by BORB
    function pal(c0,c1)
      if(c0==nil and c1==nil)then for i=0,15 do poke4(0x3FF0*2+i,i) end 
      else poke4(0x3FF0*2+c0,c1) end
    end

function shadowspr(sp,spx,spy)
    for p=0,15 do pal(p,0) end
    spr(sp,spx,spy,0)
    pal()
end
