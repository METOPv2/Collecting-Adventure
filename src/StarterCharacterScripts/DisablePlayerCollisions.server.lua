local character = script.Parent.Parent

task.defer(function()
	for _, v: Part in ipairs(character:GetChildren()) do
		if v.ClassName == "Part" or v.ClassName == "MeshPart" then
			v.CollisionGroup = "Player"
		end
	end
end)
