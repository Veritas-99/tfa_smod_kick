/*---------------------------------------------------

Credit to LeErOy NeWmAn and WHORSHIPPER for the original code that this is based on.

----------------------------------------------------*/
if SERVER then
	include("kick_animapi/boneanimlib.lua")
end
if CLIENT then	
	include("kick_animapi/cl_boneanimlib.lua") 
end

RegisterLuaAnimation('tfa_g_kick', {
	FrameData = {
		{
			BoneInfo = {
				['ValveBiped.Bip01_L_Calf'] = {
					RU = -44.555652469149
				},
				['ValveBiped.Bip01_L_Thigh'] = {
					RU = -50.441395011994
				}
			},
			FrameRate = 4
		},
		{
			BoneInfo = {
				['ValveBiped.Bip01_L_Calf'] = {
				},
				['ValveBiped.Bip01_L_Thigh'] = {
				}
			},
			FrameRate = 2
		}
	},
	Type = TYPE_GESTURE
})

local kicktime = 0.7

if !ConVarExists("kick_powerscale") then
    CreateConVar("kick_powerscale", '1', FCVAR_NOTIFY)
end

if !ConVarExists("kick_chancetoblowdoor") then
    CreateConVar("kick_chancetoblowdoor", '1', FCVAR_NOTIFY)
end

if !ConVarExists("kick_blowdoormulforce") then
    CreateConVar("kick_blowdoormulforce", '1', FCVAR_NOTIFY)
end

if !ConVarExists("kick_blowdoorforce") then
    CreateConVar("kick_blowdoorforce", '300', FCVAR_NOTIFY)
end

if !ConVarExists("kick_blowdoor") then
    CreateConVar("kick_blowdoor", '1', FCVAR_NOTIFY)
end

if !ConVarExists("kick_effect") then
    CreateConVar("kick_effect", '0', FCVAR_NOTIFY)
end

if !ConVarExists("kick_maxdamage") then
    CreateConVar("kick_maxdamage", '35', FCVAR_NOTIFY)
end

if !ConVarExists("kick_mindamage") then
    CreateConVar("kick_mindamage", '20', FCVAR_NOTIFY)
end

if !ConVarExists("kick_physmul") then
    CreateConVar("kick_physmul", '1', FCVAR_NOTIFY)
end

if !ConVarExists("kick_hitshake") then
    CreateConVar("kick_hitshake", '1', FCVAR_NOTIFY)
end

if !ConVarExists("kick_hitragdollforce") then
    CreateConVar("kick_hitragdollforce", '1', FCVAR_NOTIFY)
end

if !ConVarExists("kick_doorrespawntime") then
    CreateConVar("kick_doorrespawntime", '25', FCVAR_NOTIFY)
end

if !ConVarExists("kick_damagebyspeed") then
    CreateConVar("kick_damagebyspeed", '1', FCVAR_NOTIFY)
end

if !ConVarExists("kick_damagebyspeeddiv") then
    CreateConVar("kick_damagebyspeeddiv", '10', FCVAR_NOTIFY)
end

function CalcPlayerModelsAngle( ply )
    local defans = Angle(-90,0,0)
	if ply:Health() <= 0 then return defans end
	local StartAngle = ply:EyeAngles()
	if !StartAngle then return defans end
	local CalcAngle = Angle( (StartAngle.p)/1.1-20 , StartAngle.y, 0)
	if !CalcAngle then return StartAngle end
	return CalcAngle
end

if CLIENT then

local function Kicking( )
	local ply = LocalPlayer()
	
	if !IsValid(ply) then return end
	
    if !ply:Alive() then return false end
    if !ply.StopKick then
        ply.StopKick = CurTime() + 0.7
    elseif ply.StopKick and ply.StopKick < CurTime() then
        ply:SetNWBool("Kicking",net.ReadBool())
        ply.KickTime = CurTime()
        ply.StopKick = ply.KickTime + 0.7
    end
end
net.Receive( "Kicking", Kicking )

local kickvmoffset = Vector(3,-1.5,-8)

function CreateLegs()
for k, v in pairs(player.GetAll()) do

	local Kicking = v:GetNWBool("Kicking",false)
    if GetViewEntity() == v and (!v.ShouldDrawLocalPlayer or !v:ShouldDrawLocalPlayer() ) and Kicking and v.StopKick and v.StopKick > CurTime() then
		local off = Vector(kickvmoffset.x,kickvmoffset.y,kickvmoffset.z)
		off:Rotate(CalcPlayerModelsAngle(v))
		if !IsValid(v.CreateLegs) then
			--print("Creating Main Leg")
			v.CreateLegs = ClientsideModel("models/weapons/tfa_kick.mdl", RENDERGROUP_TRANSLUCENT)
			v.CreateLegs:Spawn()
			v.CreateLegs:SetPos(v:GetShootPos()+off)
			v.CreateLegs:SetAngles(CalcPlayerModelsAngle(v))
			v.CreateLegs:SetParent(v)
			v.CreateLegs:SetNoDraw(true)
			v.CreateLegs:DrawModel()
			v.CreateLegs:SetCycle(0)
			v.CreateLegs:SetSequence(2)
			v.CreateLegs:SetPlaybackRate( 1 ) 
			v.CreateLegs.LastTick = CurTime()
		else
			--print("Updating Main Leg")
			v.CreateLegs:SetPos(v:GetShootPos()+off)
			v.CreateLegs:SetAngles(CalcPlayerModelsAngle(v))
			v.CreateLegs:FrameAdvance( CurTime() - v.CreateLegs.LastTick )		
		    v.CreateLegs.LastTick = CurTime()
		end
		if !IsValid(v.CreatePMLegs)  then
			--print("Creating PM Leg")
			v.CreatePMLegs = ClientsideModel(string.Replace(v:GetModel(),"models/models/","models/"), RENDERGROUP_TRANSLUCENT)
			v.CreatePMLegs:Spawn()
			v.CreatePMLegs:SetParent(v.CreateLegs)
			v.CreatePMLegs:SetPos(v:GetShootPos()+off)
			v.CreatePMLegs:SetAngles(CalcPlayerModelsAngle(v))
			v.CreatePMLegs:SetNoDraw(false)
			v.CreatePMLegs:AddEffects(EF_BONEMERGE)
			v.CreatePMLegs:DrawModel()
			v.CreatePMLegs:SetPlaybackRate( 1 ) 
			v.CreatePMLegs.LastTick = CurTime()
		else
			--print("Updating PM Leg")
			v.CreatePMLegs:SetPos(v:GetShootPos()+off)
			v.CreatePMLegs:SetAngles(CalcPlayerModelsAngle(v))
			v.CreatePMLegs:FrameAdvance( CurTime() - v.CreateLegs.LastTick )
            v.CreatePMLegs:DrawModel()			
		    v.CreatePMLegs.LastTick = CurTime()
		end
	else
			
			if v.CreateLegs then
				if IsValid(v.CreateLegs) then
					v.CreateLegs.SetNoDraw(v.CreateLegs,true)
					v.CreateLegs.SetPos(v.CreateLegs,Vector(0, 0, 0))
					v.CreateLegs.SetAngles(v.CreateLegs,Angle(0,0,0))
					v.CreateLegs.SetRenderOrigin(v.CreateLegs,Vector(0, 0, 0))
					v.CreateLegs.SetRenderAngles(v.CreateLegs,Angle(0,0,0))
				end
				
				local tmpcreatelegs = v.CreateLegs
				timer.Simple(0.1,function()
					if tmpcreatelegs then
						SafeRemoveEntity(tmpcreatelegs)
					end
				end)
				
				v.CreateLegs = nil
				
			end
			
			if v.CreatePMLegs then
				--print("Removing Created PM Leg")
				if IsValid(v.CreatePMLegs) then
					v.CreatePMLegs.SetNoDraw(v.CreatePMLegs,true)
					v.CreatePMLegs.SetPos(v.CreatePMLegs,Vector(0, 0, 0))
					v.CreatePMLegs.SetAngles(v.CreatePMLegs,Angle(0,0,0))
					v.CreatePMLegs.SetRenderOrigin(v.CreatePMLegs,Vector(0, 0, 0))
					v.CreatePMLegs.SetRenderAngles(v.CreatePMLegs,Angle(0,0,0))
				end
				
				local tmpcreatelegs = v.CreatePMLegs
				timer.Simple(0.1,function()
					if tmpcreatelegs then
						SafeRemoveEntity(tmpcreatelegs)
					end
				end)
				
				v.CreatePMLegs = nil
			end
			
			v.Kicking = false
	end
end
end
hook.Add("Think","CreateLegs",CreateLegs)

local KickPanel

function KickMenu() 
    
	if not KickPanel or not KickPanel:IsValid() then
		KickPanel = vgui.Create("DFrame")
		KickPanel:SetSize(400, 600)
		KickPanel:Center()
		KickPanel:SetVisible(true)
		KickPanel:MakePopup()
		KickPanel:SetTitle("Customisable Smod Kick Menu")
		
		function KickPanel:Update()
		     
	        local CheckBox1 = vgui.Create( "DCheckBoxLabel", KickPanel )
            CheckBox1:SetPos( 40,50 )
            CheckBox1:SetText( "Kick can blow door" )
            CheckBox1:SetConVar( "kick_blowdoor" )
            CheckBox1:SizeToContents()
			
			local CheckBox2 = vgui.Create( "DCheckBoxLabel", KickPanel )
            CheckBox2:SetPos( 40,70 )
            CheckBox2:SetText( "Kick hit effect" )
            CheckBox2:SetConVar( "kick_effect" )
            CheckBox2:SizeToContents()
			
			local CheckBox3 = vgui.Create( "DCheckBoxLabel", KickPanel )
            CheckBox3:SetPos( 40,90 )
            CheckBox3:SetText( "Kick hit shake" )
            CheckBox3:SetConVar( "kick_hitshake" )
            CheckBox3:SizeToContents()
		    
			local CheckBox4 = vgui.Create( "DCheckBoxLabel", KickPanel )
            CheckBox4:SetPos( 40,30 )
            CheckBox4:SetText( "Damage by speed" )
            CheckBox4:SetConVar( "kick_damagebyspeed" )
            CheckBox4:SizeToContents()
			
			local NumSlider1 = vgui.Create( "DNumSlider", KickPanel )
            NumSlider1:SetPos( 25,110 )
            NumSlider1:SetSize( 300, 30 ) 
            NumSlider1:SetText( "Kick power scale" )
            NumSlider1:SetMin( 0 ) 
            NumSlider1:SetMax( 10000 ) 
            NumSlider1:SetDecimals( 0 ) 
            NumSlider1:SetConVar( "kick_powerscale" ) 
			
			local NumSlider2 = vgui.Create( "DNumSlider", KickPanel )
            NumSlider2:SetPos( 25,150 )
            NumSlider2:SetSize( 300, 30 ) 
            NumSlider2:SetText( "Chance to blow door" )
            NumSlider2:SetMin( 1 ) 
            NumSlider2:SetMax( 10 ) 
            NumSlider2:SetDecimals( 0 ) 
            NumSlider2:SetConVar( "kick_chancetoblowdoor" ) 
			
			local NumSlider3 = vgui.Create( "DNumSlider", KickPanel )
            NumSlider3:SetPos( 25,190 )
            NumSlider3:SetSize( 300, 30 ) 
            NumSlider3:SetText( "Kick blow door mul force" )
            NumSlider3:SetMin( 1 ) 
            NumSlider3:SetMax( 1000 ) 
            NumSlider3:SetDecimals( 0 ) 
            NumSlider3:SetConVar( "kick_blowdoormulforce" ) 
			
			local NumSlider4 = vgui.Create( "DNumSlider", KickPanel )
            NumSlider4:SetPos( 25,230 )
            NumSlider4:SetSize( 300, 30 ) 
            NumSlider4:SetText( "Kick blow door force" )
            NumSlider4:SetMin( 1 ) 
            NumSlider4:SetMax( 1000 ) 
            NumSlider4:SetDecimals( 0 ) 
            NumSlider4:SetConVar( "kick_blowdoorforce" )

            local NumSlider5 = vgui.Create( "DNumSlider", KickPanel )
            NumSlider5:SetPos( 25,270 )
            NumSlider4:SetSize( 300, 30 ) 
            NumSlider5:SetText( "Kick max damage" )
            NumSlider5:SetMin( 1 ) 
            NumSlider5:SetMax( 1000 ) 
            NumSlider5:SetDecimals( 0 ) 
            NumSlider5:SetConVar( "kick_maxdamage" ) 			
			
			local NumSlider5 = vgui.Create( "DNumSlider", KickPanel )
            NumSlider5:SetPos( 25,310 )
            NumSlider4:SetSize( 300, 30 )  
            NumSlider5:SetText( "Kick min damage" )
            NumSlider5:SetMin( 1 ) 
            NumSlider5:SetMax( 1000 ) 
            NumSlider5:SetDecimals( 0 ) 
            NumSlider5:SetConVar( "kick_mindamage" ) 			
			
			local NumSlider6 = vgui.Create( "DNumSlider", KickPanel )
            NumSlider6:SetPos( 25,350 )
            NumSlider4:SetSize( 300, 30 ) 
            NumSlider6:SetText( "Kick phys mul" )
            NumSlider6:SetMin( 1 ) 
            NumSlider6:SetMax( 1000 ) 
            NumSlider6:SetDecimals( 0 ) 
            NumSlider6:SetConVar( "kick_physmul" ) 	
			
			local NumSlider7 = vgui.Create( "DNumSlider", KickPanel )
            NumSlider7:SetPos( 25,390 )
            NumSlider4:SetSize( 300, 30 ) 
            NumSlider7:SetText( "Kick hit ragdoll force" )
            NumSlider7:SetMin( 1 ) 
            NumSlider7:SetMax( 1000 ) 
            NumSlider7:SetDecimals( 0 ) 
            NumSlider7:SetConVar( "kick_hitragdollforce" ) 	
			
			local NumSlider8 = vgui.Create( "DNumSlider", KickPanel )
            NumSlider8:SetPos( 25,430 )
            NumSlider4:SetSize( 300, 30 ) 
            NumSlider8:SetText( "Door respawn time" )
            NumSlider8:SetMin( 1 ) 
            NumSlider8:SetMax( 60 ) 
            NumSlider8:SetDecimals( 0 ) 
            NumSlider8:SetConVar( "kick_doorrespawntime" ) 	
			
			local NumSlider8 = vgui.Create( "DNumSlider", KickPanel )
            NumSlider8:SetPos( 25,470 )
            NumSlider4:SetSize( 300, 30 ) 
            NumSlider8:SetText( "Damage by speed divider" )
            NumSlider8:SetMin( 1 ) 
            NumSlider8:SetMax( 100 ) 
            NumSlider8:SetDecimals( 0 ) 
            NumSlider8:SetConVar( "kick_damagebyspeeddiv" ) 
			

		end
		
		KickPanel:Update()
		
	else
		KickPanel:SetVisible(false)
	end

end

concommand.Add("Kick_Menu", KickMenu)
usermessage.Hook("Kick_Menu", KickMenu)

end

function kickReset()

    CreateConVar("kick_powerscale", '1', FCVAR_NOTIFY)



    CreateConVar("kick_chancetoblowdoor", '5', FCVAR_NOTIFY)



    CreateConVar("kick_blowdoormulforce", '1', FCVAR_NOTIFY)



    CreateConVar("kick_blowdoorforce", '300', FCVAR_NOTIFY)



    CreateConVar("kick_blowdoor", '1', FCVAR_NOTIFY)



    CreateConVar("kick_effect", '1', FCVAR_NOTIFY)



    CreateConVar("kick_maxdamage", '35', FCVAR_NOTIFY)



    CreateConVar("kick_mindamage", '20', FCVAR_NOTIFY)



    CreateConVar("kick_physmul", '5', FCVAR_NOTIFY)



    CreateConVar("kick_hitshake", '1', FCVAR_NOTIFY)



    CreateConVar("kick_hitragdollforce", '100', FCVAR_NOTIFY)



    CreateConVar("kick_doorrespawntime", '25', FCVAR_NOTIFY)



    CreateConVar("kick_damagebyspeed", '1', FCVAR_NOTIFY)



    CreateConVar("kick_damagebyspeeddiv", '10', FCVAR_NOTIFY)

print("Reset Variables")
end
concommand.Add("Kick_Reset", kickReset)

function KickHit(ply)
	
    local damage = math.random(GetConVarNumber("kick_mindamage"),GetConVarNumber("kick_maxdamage")) * GetConVarNumber("kick_powerscale")
	
	if GetConVarNumber("kick_damagebyspeed") >= 1 then
	    damage = damage + math.Clamp(ply:GetVelocity():Length() / GetConVarNumber("kick_damagebyspeeddiv"), 0, ply:GetVelocity():Length())
	end
	
	if ply:GetNWBool("Extention_Strength") then
	    damage = damage * 3
	end
	
	
	-- local bul = {}
	-- bul.Attack = ply
	-- bul.Damage = damage
	-- bul.Force = ((damage * GetConVarNumber("kick_hitragdollforce") * GetConVarNumber("kick_physmul")) * GetConVarNumber("kick_powerscale"))
	-- bul.Distance = 85
	-- bul.HullSize = 0
	-- bul.Tracer = 0
	-- bul.TracerName = "TeslaZap"
	-- bul.Dir = ply:EyeAngles():Forward()
	-- bul.Src = ply:GetShootPos()
	-- bul.Callback = function(ply, trace, damageinfo)
	local physForce = ((damage * GetConVarNumber("kick_hitragdollforce") * GetConVarNumber("kick_physmul")) * GetConVarNumber("kick_powerscale"))
	local trace = ply:GetEyeTraceNoCursor()
		if !trace then print(notrace) end
		if SERVER then
			if trace.HitPos:Distance(ply:GetShootPos()) <= 89 then -- If we're in range
				if GetConVarNumber("kick_hitshake") >= 1 then
					util.ScreenShake( trace.HitPos, 2500,255, 0.5, 150 )
				end
				
				if trace.MatType == MAT_FLESH then
					if trace.Entity:Health() < 1 then
						local boneNum = trace.Entity:LookupBone("ValveBiped.Bip01_Spine")
						local physBoneNum = trace.Entity:TranslateBoneToPhysBone(boneNum)
						local physBone = trace.Entity:GetPhysicsObjectNum(physBoneNum)
						physBone:SetVelocity(trace.Normal * physForce * 50)
					else
						local dmgInfo = DamageInfo()
						dmgInfo:SetAttacker(ply)
						dmgInfo:SetDamage(100)
						dmgInfo:SetDamageForce(trace.Normal * physForce * 250)
						dmgInfo:SetDamagePosition(ply:GetPos())
						trace.Entity:TakeDamageInfo(dmgInfo)
					end
					trace.Entity:EmitSound("player/smod_kick/foot_kickbody.wav", 100, math.random(80, 110))
					local fx=EffectData()
					fx:SetStart(trace.HitPos)
					fx:SetOrigin(trace.HitPos)
					fx:SetNormal(trace.Normal)
					util.Effect("BloodImpact",fx)
				else
					ply:EmitSound("player/smod_kick/foot_kickwall.wav", 100, math.random(80, 110))
					local physObj = trace.Entity:GetPhysicsObject()
					physObj:SetVelocity(trace.Normal * physForce * 7.5)
					trace.Entity:TakeDamage(damage)
					 if GetConVarNumber("kick_effect") >= 1 then		
						local fx 	= EffectData()
						fx:SetStart(trace.HitPos)
						fx:SetOrigin(trace.HitPos)
						fx:SetNormal(trace.HitNormal)
						util.Effect("kick_groundhit",fx)
					end		
				end
				
				ply:ViewPunch( Angle( -10, math.random( -5, 5 ), 0 ) );
				
				if trace.Entity:GetClass() == "func_door_rotating" or trace.Entity:GetClass() == "prop_door_rotating" then
					if math.random(1,GetConVarNumber("kick_chancetoblowdoor")) == 1 and GetConVarNumber("kick_blowdoor") >= 1 and trace.Entity:GetClass() == "prop_door_rotating" then
						FakeDoor(trace.Entity, ply, damage)
						ply:EmitSound("ambient/materials/door_hit1.wav", 100, math.random(80, 120))
					else	
						ply:EmitSound("ambient/materials/door_hit1.wav", 100, math.random(80, 120))
						
						ply.oldname = ply:GetName()
						
						ply:SetName( "kickingpl" .. ply:EntIndex() )
						
						trace.Entity:SetKeyValue( "Speed", "500" )
						trace.Entity:SetKeyValue( "Open Direction", "Both directions" )
						trace.Entity:Fire( "unlock", "", .01 )
						trace.Entity:Fire( "openawayfrom", "kickingpl" .. ply:EntIndex() , .01 )
						
						timer.Simple(0.02, function()
							if IsValid(ply) then
								ply:SetName(ply.oldname)
							end
						end)
						
						timer.Simple(0.3, function()
							if IsValid(trace.Entity) then
								trace.Entity:SetKeyValue( "Speed", "100" )
							end
						end)
						
					end
				-- end
			end
		end
	
	end
	
	-- ply:FireBullets( bul, false)
	ply:EmitSound("player/smod_kick/foot_fire.wav", 100, math.random(70, 110))
	
	--[[
	if trace == nil or trace.HitSky then return end
    local phys = trace.Entity:GetPhysicsObject()
	if phys == nil then return end
	
    local damage = math.random(GetConVarNumber("kick_mindamage"),GetConVarNumber("kick_maxdamage")) * GetConVarNumber("kick_powerscale")
	
	if GetConVarNumber("kick_damagebyspeed") >= 1 then
	    damage = damage + math.Clamp(ply:GetVelocity():Length() / GetConVarNumber("kick_damagebyspeeddiv"), 0, ply:GetVelocity():Length())
	end
	
	if ply:GetNWBool("Extention_Strength") then
	    damage = damage * 3
	end

    if SERVER then
    if trace.HitPos:Distance(ply:GetShootPos()) <= 85 then -- If we're in range
	    if GetConVarNumber("kick_hitshake") >= 1 then
			util.ScreenShake( trace.HitPos, 2500,255, 0.5, 150 )
		end	
        if trace.Entity:IsPlayer() or string.find(trace.Entity:GetClass(),"npc") or string.find(trace.Entity:GetClass(),"prop_ragdoll") then	
	        if string.find(trace.Entity:GetClass(),"npc") and trace.Entity:Health() <= damage then
	            phys:ApplyForceOffset(ply:GetAimVector():GetNormalized() * (damage * GetConVarNumber("kick_physmul")), trace.HitPos)
	            trace.Entity:SetVelocity(ply:GetAimVector():GetNormalized() * (damage * GetConVarNumber("kick_physmul")))
			elseif string.find(trace.Entity:GetClass(),"prop_ragdoll") then
			    phys:ApplyForceOffset(ply:GetAimVector():GetNormalized() * ((damage * GetConVarNumber("kick_hitragdollforce") * GetConVarNumber("kick_physmul")) * GetConVarNumber("kick_powerscale")), trace.HitPos)
	        end
			trace.Entity:EmitSound("player/smod_kick/foot_kickbody.wav", 100, math.random(80, 110))
			ply:ViewPunch( Angle( -10, math.random( -5, 5 ), 0 ) );
	        trace.Entity:TakeDamage(damage, ply, ply)
	    elseif trace.Entity:IsWorld() then
			ply:EmitSound("player/smod_kick/foot_kickwall.wav", 100, math.random(70, 140))
			ply:ViewPunch( Angle( -10, math.random( -5, 5 ), 0 ) );
			 if GetConVarNumber("kick_effect") >= 1 then		
			    local fx 	= EffectData()
	            fx:SetStart(trace.HitPos)
	            fx:SetOrigin(trace.HitPos)
	            fx:SetNormal(trace.HitNormal)
	            util.Effect("kick_groundhit",fx)
	        end			
		elseif trace.Entity:GetClass() == "func_door_rotating" or trace.Entity:GetClass() == "prop_door_rotating" then
		    if math.random(1,GetConVarNumber("kick_chancetoblowdoor")) == 1 and GetConVarNumber("kick_blowdoor") >= 1 and trace.Entity:GetClass() == "prop_door_rotating" then
			    FakeDoor(trace.Entity, ply, damage)
				ply:EmitSound("ambient/materials/door_hit1.wav", 100, math.random(80, 120))
	            ply:ViewPunch( Angle( -10, math.random( -5, 5 ), 0 ) );
			else	
		        ply:EmitSound("ambient/materials/door_hit1.wav", 100, math.random(80, 120))
				trace.Entity:SetKeyValue( "Speed", "500" )
			    trace.Entity:Fire( "unlock", "", .01 )
	            trace.Entity:Fire( "open", "", .01 )
				timer.Simple(0.3, function()
				    trace.Entity:SetKeyValue( "Speed", "100" )
				end, trace.Entity)
	            ply:ViewPunch( Angle( -10, math.random( -5, 5 ), 0 ) );
			end
            if GetConVarNumber("kick_effect") >= 1 then		
			    local fx 	= EffectData()
	            fx:SetStart(trace.HitPos)
	            fx:SetOrigin(trace.HitPos)
	            fx:SetNormal(trace.HitNormal)
	            util.Effect("kick_groundhit",fx)
	        end			
		elseif trace.Entity:IsValid() then	
	        phys:ApplyForceOffset(ply:GetAimVector():GetNormalized() * (damage * 100 * GetConVarNumber("kick_physmul")), trace.HitPos)
	        trace.Entity:SetVelocity(ply:GetAimVector():GetNormalized() * (damage * 100 * GetConVarNumber("kick_physmul")))
			ply:EmitSound("player/smod_kick/foot_kickwall.wav", 100, math.random(80, 110))
			ply:ViewPunch( Angle( -10, math.random( -5, 5 ), 0 ) );
	        trace.Entity:TakeDamage(damage, ply, ply)	
	    end 
	
	else
	    ply:EmitSound("player/smod_kick/foot_fire.wav", 100, math.random(70, 110))
		ply:ViewPunch( Angle( -10, math.random( -5, 5 ), 0 ) );
	end
    end
	]]--
end
-- thanks worshipper 8D
function FakeDoor(Door, attacker, amount)

        local pos = Door:GetPos()
		local ang = Door:GetAngles()
		local model = Door:GetModel()
		local skin = Door:GetSkin()

		Door:SetNotSolid(true)
		Door:SetNoDraw(true)

		local function ResetDoor(door, fakedoor)
		if door:IsValid() then
		local mass = door:GetNWInt("DoorHealthMaxHealth")
			door:SetNotSolid(false)
			door:SetNoDraw(false)
			door.DoorHealth = mass
	        door:SetNWInt("DoorHealth", door.DoorHealth )
			end
			if fakedoor:IsValid() then
			fakedoor:Remove()
			end
		end

		local ent = ents.Create("prop_physics")
		ent:SetPos(pos)
		ent:SetAngles(ang)
		ent:SetModel(model)
		if skin then
			ent:SetSkin(skin)
		end
		ent:Spawn()
		ent:EmitSound("physics/wood/wood_furniture_break"..math.random(1,2)..".wav", 100, math.random(70, 140))
		ent:SetVelocity(attacker:GetAimVector() * (amount * GetConVarNumber("kick_blowdoorforce")) * GetConVarNumber("kick_blowdoormulforce"))
		ent:GetPhysicsObject():ApplyForceCenter(attacker:GetAimVector() * (amount * GetConVarNumber("kick_blowdoorforce")) * GetConVarNumber("kick_blowdoormulforce"))
		
		
end

if (SERVER) then 
	util.AddNetworkString( "Kicking" )
	
	function KickingComm(ply)

		if !ply:Alive() then return false end
		if ply.StopKick and ply.StopKick < CurTime() then
			ply:SetNWBool("Kicking",true)
			ply.KickTime = CurTime()
			ply.StopKick = ply.KickTime + kicktime
			timer.Simple(kicktime, function()
				if IsValid(ply) then
					ply:SetNWBool("Kicking",false)
				end
			end)
			if ply.SetLuaAnimation then
				ply:SetLuaAnimation("tfa_g_kick")
			end
			net.Start("Kicking")
			net.WriteBool(true)
			net.Send(ply)
			timer.Simple(0.15, function()
				KickHit(ply)
			end, ply)
		end
	end
	
	concommand.Add("KickingComm",KickingComm)

	function KickPlayerStart(ply)
		ply.Kicking = false
		ply.KickTime = -1
		ply.StopKick = ply.KickTime + kicktime
	end
	hook.Add("PlayerSpawn","KickPlayerStart",KickPlayerStart)

	function KickPlayerDeath(ply)
		ply.Kicking = false
		ply.KickTime = -1
		ply.StopKick = ply.KickTime + kicktime
	end

	hook.Add("PlayerDeath","KickPlayerDeath",KickPlayerDeath)

end