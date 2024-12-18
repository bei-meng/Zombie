local assets =
{
	Asset("ANIM", "anim/zskb_mountain_spirit_egg.zip"),
	Asset("SOUNDPACKAGE", "sound/zskb_mountain_spirit.fev"),
	Asset("SOUND", "sound/zskb_mountain_spirit.fsb"),
}

local function fn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()

	inst.AnimState:SetRayTestOnBB(true);
	MakeInventoryPhysics(inst)

	inst.AnimState:SetBank("zskb_mountain_spirit_egg")
	inst.AnimState:SetBuild("zskb_mountain_spirit_egg")
	inst.Transform:SetScale(1.15, 1.15, 1.15)

	inst.AnimState:PlayAnimation("idle", true)

	inst:AddTag("explosive")
	inst:AddTag("zskb_mountain_spirit_egg")

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst:SetStateGraph("SGzskb_mountain_spirit_egg")

	inst.persists = false

	return inst
end

return Prefab("zskb_mountain_spirit_egg", fn, assets)
