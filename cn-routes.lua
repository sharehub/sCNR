#!/bin/env lua

--[[
 working for Lua5.2 only 
 This is based on http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest
 And CN|ipv4 is used here
 It is not exactly, but try to make the route table small
 Author: leon@sharehub.github.io
--]]

--[[ CONFIGRUATION --]]

-- FILE
local CNR_APNIC = "http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest"

-- CouNtry CODE	-- you could define you own for other country
local CNR_CNCODE = "CN"

local CNR_IPVER = "ipv4" -- ip version

local CNR_PURE_IP = false	-- pure IP/mask or OpenVPN

-- ignore ip who's rang less than this will be merged
local GAP=2^19

--[[ END CONFIGRUATION --]]



local bit32 = require("bit32")
local string = require("string")

-- make ip to int 
local function ip2int(str)
	o1,o2,o3,o4 = str:match("(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)" )
	return (2^24*o1 + 2^16*o2 + 2^8*o3 + o4)
end

-- make the int value to a IP
local function int2ip(i)
  o4 = bit32.extract(i,0, 8) 
  o3 = bit32.extract(i,8, 8) 
  o2 = bit32.extract(i,16, 8) 
  o1 = bit32.extract(i,24, 8)
  return o1.."."..o2.."."..o3.."."..o4 
end

-- make int to mask
local function getint2mask()
  mask = {}
  return function(i)
    if mask[i] then return mask[i] end
    mask[i] = int2ip(bit32.bnot(2^i-1))
    return mask[i]
  end
end

local int2mask = getint2mask()

-- make a rang value to a mask
local exp2 = {} -- make it global
local function getrang2mask()
  return function(rang)
    for j = 1, 32 do
      if not exp2[j] then
        exp2[j] = 2^j
      end
      if exp2[j] >= rang then
	return int2mask(j)
      end
    end
    error("mask "..i.." not valid!")
  end
end

local rang2mask = getrang2mask()

local lastmerge = nil	-- we want recurration
local rangcheck = nil	-- we want recurration

lastmerge = function (tbl)
  lastr = tbl[#tbl-1]
  curr = tbl[#tbl]
  if lastr and lastr.iend > curr.start then
    lastr.iend = curr.iend
    tbl[#tbl] = nil
    rangcheck(tbl)
    lastmerge(tbl) -- merge again
  end 
end

-- Let check it again
rangcheck = function (tbl)
  rg = tbl[#tbl].iend - tbl[#tbl].start
  for i = 1, 32 do
    if not exp2[i] then
      exp2[i] = 2^i
    end
    if exp2[i] >= rg then
      tbl[#tbl].start = bit32.band(tbl[#tbl].start, bit32.bnot(exp2[i]-1))
      tbl[#tbl].iend = tbl[#tbl].start + exp2[i]
      lastmerge(tbl)
      return
    end
  end
end

-- merge the IP that less than GAP
local function ipmerge(tbl, cur)
  if #tbl == 0 then
    tbl[#tbl+1] = cur
    return
  end

  if cur.start - tbl[#tbl].iend < GAP then
    tbl[#tbl].iend = cur.iend	-- merge it
    -- After merge, the IP's start address may not current, we need fix it and merge it again #tbl-1
    -- rangcheck(tbl) 
  else			-- > GAP, will start next, but we need rangcheck again
    rangcheck(tbl)
    if cur.start - tbl[#tbl].iend < GAP then
      tbl[#tbl].iend = cur.iend
    else
      tbl[#tbl+1] = cur
    end
  end
end

-- Get files, should use luasocket but it not compatible with Lua5.2
os.execute("wget "..CNR_APNIC)
local filename = {string.match(CNR_APNIC, "(.-)([^\\/]-%.?([^%.\\/]*))$")}
filename = filename[#filename]

--[[
 main here
--]]

io.input(filename)

-- init table
local tbl = {} 
for line in io.lines() do
  fileiter = string.gmatch(line, "([^|]+)")
  apnic = fileiter()
  cncode = fileiter()
  type = fileiter()
  ipstr = fileiter()
  rang = fileiter()

  if cncode == CNR_CNCODE and type == CNR_IPVER then
    -- print(line)
    ipint = ip2int(ipstr)
    ipmerge(tbl, {start=ipint, iend=ipint+rang})
  end
end

--[[
for i = 1, #tbl do
   print(tbl[i].start, tbl[i].iend)
end
--]]

for i=1, #tbl do
  rg = tbl[i].iend-tbl[i].start
  if CNR_PURE_IP then
    print(int2ip(tbl[i].start), rang2mask(rg))
  else
    print("route ", int2ip(tbl[i].start), rang2mask(rg), "net_gateway")
  end
end
