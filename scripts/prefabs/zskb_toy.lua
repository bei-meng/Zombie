local assets =
{
    Asset("ANIM", "anim/zskb_toy.zip"),
}

local function MakeTrinket(name)
    local prefabs = {}

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank("zskb_toy")
        inst.AnimState:SetBuild("zskb_toy")
        inst.AnimState:PlayAnimation(name)

        inst:AddTag("molebait") --鼹鼠诱饵
        inst:AddTag("cattoy")   --猫玩具
        inst:AddTag("zskb_toy") --mod专属玩具标签

        MakeInventoryFloatable(inst)

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("inspectable")
        inst:AddComponent("stackable")
        inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

        inst:AddComponent("inventoryitem")
        inst.components.inventoryitem.atlasname = "images/zskb_inventoryimages.xml"

        inst:AddComponent("tradable")
        inst.components.tradable.coppercoin = 1

        MakeHauntableLaunchAndSmash(inst)

        inst:AddComponent("bait")

        return inst
    end

    return Prefab(name, fn, assets, prefabs)
end

local ret = {}
table.insert(ret, MakeTrinket("zskb_bell"))              --铃铛
table.insert(ret, MakeTrinket("zskb_blessing"))          --福
table.insert(ret, MakeTrinket("zskb_bull_head_statue"))  --牛头人雕像
table.insert(ret, MakeTrinket("zskb_comb"))              --梳子
table.insert(ret, MakeTrinket("zskb_embroidered_shoes")) --绣花鞋
table.insert(ret, MakeTrinket("zskb_hydrangea"))         --红绣球
table.insert(ret, MakeTrinket("zskb_ingot"))             --元宝
table.insert(ret, MakeTrinket("zskb_reel"))              --卷轴
table.insert(ret, MakeTrinket("zskb_scissors"))          --剪刀
table.insert(ret, MakeTrinket("zskb_broken_pages1"))     --残破书页1
table.insert(ret, MakeTrinket("zskb_broken_pages2"))     --残破书页2
table.insert(ret, MakeTrinket("zskb_broken_pages3"))     --残破书页3

return unpack(ret)
