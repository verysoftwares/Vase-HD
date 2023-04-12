function inv_len()
    local i=1
    while fget(mget(x,y-i),2) do
        i=i+1
    end
    return i-1
end

function inv_rem(iy)
    local i=0
    while fget(mget(x,iy-i),2) do
        if fget(mget(x,iy-i-1),2) then
        mset(x,iy-i,mget(x,iy-i-1))
        else mset(x,iy-i,0) end
        i=i+1
    end
end

function next_drop()
    if mget(x,y-1)==61 then
        local cx,cy=117,64
        while mget(cx,cy)>=0 do
            if mget(cx,cy)>0 then return mget(cx,cy),cx,cy end
            cx=cx+1
            if cx==120 then cx=117; cy=cy+1; if cy>65 then break end end
        end
    end
    return mget(x,y-1),x,y-1
end

function box_full()
    if mget(x,y-1)==61 then
        local cx,cy=119,65
        while mget(cx,cy)>0 do
            cx=cx-1
            if cx==116 then cx=119; cy=cy-1; if cy<64 then return true end end
        end
    end
    return false
end
