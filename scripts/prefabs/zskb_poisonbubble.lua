local assets =
{
	--Asset("ANIM", "anim/zskb_poison.zip"),
	--Asset("SOUND", "sound/common.fsb"),

	Asset("ANIM", "anim/poison.zip"),
	Asset("SOUNDPACKAGE", "sound/zskb_poison_bubble.fev"),
	Asset("SOUND", "sound/zskb_poison_bubble.fsb"),
}

local function PlayBubbleSound(inst)
	inst.SoundEmitter:PlaySound("zskb_poison_bubble/zskb_poison_bubble/poisoned", "poisoned")
end

local function kill(inst)
	inst.SoundEmitter:KillSound("poisoned")
	if inst.sound_task then
		inst.sound_task:Cancel()
		inst.sound_task = nil
	end
	inst:Remove()
end

local function SetLevelAndBubbles(inst, level)
	inst.level = level
	inst.AnimState:PlayAnimation("level" .. inst.level .. "_pre")
	inst.AnimState:PushAnimation("level" .. inst.level .. "_loop", true)
end


local function StopBubbles(inst)
	inst.AnimState:PushAnimation("level" .. inst.level .. "_pst", false)
	inst:RemoveEventCallback("animqueueover", StopBubbles)
	inst:ListenForEvent("animqueueover", kill)
	inst.persists = false
end

local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local sound = inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()

	anim:SetBank("poison")
	--anim:SetBuild("zskb_poison")

	inst.AnimState:SetBuild("poison")
	inst.AnimState:SetMultColour(0, 0, .1, 1)

	SetLevelAndBubbles(inst, 1)

	inst.sound_task = inst:DoPeriodicTask(10, PlayBubbleSound, 0)

	inst:AddTag("FX")
	inst:AddTag("HASHEATER")
	inst.entity:SetPristine()

	inst.StopBubbles = StopBubbles
	inst.SetLevelAndBubbles = SetLevelAndBubbles

	anim:SetFinalOffset(2)

	if not TheWorld.ismastersim then
		return inst
	end

	return inst
end


return Prefab("zskb_poisonbubble", fn, assets)
