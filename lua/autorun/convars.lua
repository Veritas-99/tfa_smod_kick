require("sharedvars")

if not ConVarExists("kick_teams") then
	CreateConVar("kick_teams", "", FCVAR_NONE)
	cvars.AddChangeCallback("kick_teams", function(name, oVal, nVal)
		Gkick_teams = string.Split(string.Replace(nVal, " ", ""), ",")
	end)
end