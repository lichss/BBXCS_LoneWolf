::Zlonewolf <- {
	ID = "zlonewolf",
	Name = "Zlonewolf",
	Version = 1.0.0
}
::mods_registerMod(::Zlonewolf.ID, ::Zlonewolf.Version, ::Zlonewolf.Name);

::mods_queue(::Zlonewolf.ID, "", function()
{

	// ==========================================
	// 1. 劫持特质的类原型：修改酒鬼特质
	// ==========================================
	::mods_hookExactClass("skills/traits/drunkard_trait", function(o) 
	{
		// 覆写前端 UI 显示逻辑
		o.getTooltip = function()
		{
			return [
				{
					id = 1,
					type = "title",
					text = this.getName()
				},
				{
					id = 2,
					type = "description",
					text = this.getDescription()
				},
				{
					id = 10,
					type = "text",
					icon = "ui/icons/regular_damage.png",
					text = "[color=" + this.Const.UI.Color.PositiveValue + "]+15%[/color] Damage"
				},
				{
					id = 11,
					type = "text",
					icon = "ui/icons/bravery.png",
					text = "[color=" + this.Const.UI.Color.PositiveValue + "]+5[/color] Resolve"
				},
				{
					id = 12,
					type = "text",
					icon = "ui/icons/melee_skill.png",
					text = "[color=" + this.Const.UI.Color.NegativeValue + "]-5[/color] Melee Skill"
				},
				{
					id = 13,
					type = "text",
					icon = "ui/icons/ranged_skill.png",
					text = "[color=" + this.Const.UI.Color.NegativeValue + "]-10[/color] Ranged Skill"
				}
			];
		}

		// 覆写底层属性计算逻辑
		o.onUpdate = function( _properties )
		{
			_properties.DamageTotalMult *= 1.15;
			_properties.Bravery += 5;
			_properties.MeleeSkill += -5;
			_properties.RangedSkill += -10;
		}
	});

	// ==========================================
	// 2. 劫持物品对象：修改兽人双手大斧
	// ==========================================
	::mods_hookNewObject("items/weapons/greenskins/orc_axe_2h", function(o) {
		o.m.RegularDamage = 100;
		o.m.RegularDamageMax = 130;
		o.m.ArmorDamageMult = 1.6;
		o.m.ShieldDamage = 42;
		o.m.DirectDamageMult = 0.45;
		o.m.Value = 3000;
		o.m.FatigueOnSkillUse = 5;
	});

	// ==========================================
	// 2. 劫持物品对象：战旗
	// ==========================================
	::mods_hookNewObject("items/weapons/warbrand", function(o) {
		o.m.RegularDamage = 65;
		o.m.RegularDamageMax = 80;
		o.m.ArmorDamageMult = 1.0;
		o.m.DirectDamageMult = 0.3;
		o.m.StaminaModifier = 0;
		o.m.Value = 3000;
	});


	// ==========================================
	// 3. 拦截特质实例化：修改玩家主角专属特质 (对象级覆写)
	// ==========================================
	::mods_hookNewObject("skills/traits/player_character_trait", function(o) 
	{
		// --- 1. 注入实例级状态变量 ---
		// o 此时是已经完全实例化的对象，直接操作其 m 表
		o.m.Kills <- 0; 

		// --- 2. 实例级方法覆写：利用委托机制拦截基类事件 ---
		// 此时对象已继承基类，可以直接提取原始函数闭包
		local onCombatStarted_original = o.onCombatStarted;
		o.onCombatStarted <- function()
		{
			onCombatStarted_original();
			this.m.Kills = 0;
		}

		local onCombatFinished_original = o.onCombatFinished;
		o.onCombatFinished <- function()
		{
			onCombatFinished_original();
			this.m.Kills = 0;
		}

		local onTargetKilled_original = o.onTargetKilled;
		o.onTargetKilled <- function( _targetEntity, _skill )
		{
			onTargetKilled_original(_targetEntity, _skill);
			if (_targetEntity != null && !_targetEntity.isAlliedWith(this.getContainer().getActor()))
			{
				this.m.Kills += 1;
			}
		}

		// --- 3. 接管前端 UI 显示逻辑 ---
		local getTooltip_original = o.getTooltip;
		o.getTooltip <- function()
		{
			local ret = [
				{
					id = 1,
					type = "title",
					text = this.getName()
				},
				{
					id = 2,
					type = "description",
					text = this.getDescription()
				},
				{
					id = 10,
					type = "text",
					icon = "ui/icons/bravery.png",
					text = "[color=" + this.Const.UI.Color.PositiveValue + "]+20[/color] Resolve"
				},
				{
					id = 11,
					type = "text",
					icon = "ui/icons/regular_damage.png",
					text = "[color=" + this.Const.UI.Color.PositiveValue + "]+25%[/color] Damage"
				},
				{
					id = 12,
					type = "text",
					icon = "ui/icons/chance_to_hit_head.png",
					text = "[color=" + this.Const.UI.Color.PositiveValue + "]+30%[/color] Chance To Hit Head"
				}
			];

			if (this.m.Kills > 0)
			{
				ret.push({
					id = 15,
					type = "text",
					icon = "ui/icons/regular_damage.png",
					text = "[color=" + this.Const.UI.Color.PositiveValue + "]+" + (this.m.Kills * 5) + "%[/color] 杀戮增伤 (" + this.m.Kills + " 层)"
				});
			}

			return ret;
		}

		// --- 4. 接管底层属性计算逻辑 ---
		local onUpdate_original = o.onUpdate;
		o.onUpdate <- function( _properties )
		{
			/* 基础属性修正 加算 */
			_properties.Bravery += 20;
			_properties.MeleeDefense += 35;
			_properties.RangedDefense += 35;
			
			/* 基础属性修正 乘算 */
			_properties.MeleeSkillMult *= 3.0;
			_properties.RangedSkillMult *= 3.0;
			_properties.MeleeDefenseMult *= 3.0;
			_properties.RangedDefenseMult *= 3.0;
			_properties.FatigueRecoveryRateMult *= 2.0;
			_properties.BraveryMult *= 2.0;
			_properties.InitiativeMult *= 3.0;

			/* 免疫 */
			_properties.IsImmuneToStun = true;
			_properties.IsImmuneToDaze = true;
			_properties.IsImmuneToRoot = true;
			_properties.IsImmuneToDisarm = true;

			_properties.IsAffectedByNight = false;
			_properties.IsAffectedByInjuries = false;
			
			_properties.DamageTotalMult *= 1.25; 
			_properties.HitChance[this.Const.BodyPart.Head] += 30; 
			_properties.Vision += 4;
			_properties.FatigueRecoveryRate += 8;
			_properties.ActionPoints += 2;

			/* 动态属性修正：击杀倍率叠加 */
			if (this.m.Kills > 0)
			{
				_properties.DamageTotalMult *= this.Math.pow(1.05, this.m.Kills);
			}
		}
	});
	// ==========================================
	//随从斥候移速提升至 25%
	// ==========================================
	::mods_hookExactClass("retinue/followers/scout_follower", function(o) 
	{
		// 1. 劫持 UI 文本：因为文本是在 create 里生成的，我们需要先存下原版函数
		local create_original = o.create;
		o.create = function()
		{
			// 先执行原版的初始化，生成名字、图标、解锁条件等信息
			create_original();
			
			// 然后强行篡改 Effects 数组里的第一条文本，改为 25%
			this.m.Effects[0] = "Makes the company travel 25% faster on any terrain";
		}

		// 2. 劫持底层逻辑：覆写移速乘区
		o.onUpdate = function()
		{
			// 将遍历地形的乘数从 1.15 修改为 1.25
			for( local i = 0; i < this.World.Assets.m.TerrainTypeSpeedMult.len(); i = ++i )
			{
				this.World.Assets.m.TerrainTypeSpeedMult[i] *= 1.80;
			}

			this.World.Assets.m.RepairSpeedMult *= 1.2;
			this.World.Assets.m.ArmorPartsPerArmor *= 0.8;
			this.World.Assets.m.IsBlacksmithed = true;
			/* 厨师 */ 
			this.World.Assets.m.FoodAdditionalDays = 8;
			this.World.Assets.m.AdditionalHitpointsPerHour += 1;

			/* 铁匠 */
			this.World.Assets.m.RepairSpeedMult *= 1.2;
			this.World.Assets.m.ArmorPartsPerArmor *= 0.8;
			this.World.Assets.m.IsBlacksmithed = true;

			/* 征募员 */
			this.World.Assets.m.RosterSizeAdditionalMin += 2;
			this.World.Assets.m.RosterSizeAdditionalMax += 4;
			this.World.Assets.m.HiringCostMult *= 0.9;
			this.World.Assets.m.TryoutPriceMult *= 0.1;

			/*是兄弟就跟我一起吃苦 */
			this.World.Assets.m.DailyWageMult *= 0.50;
		}
	});

	// ==========================================
	// 8. 商店进货：防具店老板的“柜台私货”
	// ==========================================
	::mods_hookExactClass("entity/world/settlements/buildings/armorsmith_building", function(o) 
	{
		local onUpdateShopList_original = o.onUpdateShopList;

		o.onUpdateShopList = function()
		{
			// 1. 呼叫你发给我的那段原版长代码，让老板按正常概率进货
			onUpdateShopList_original();
			
			// 2. 原版进货完毕后，强行在货架（Stash）追加我们的专属面罩
			// 这样写的好处是 100% 刷新，不用去赌原版那个 'R' 的概率，方便你测试
			// this.m.Stash.add(this.new("scripts/items/helmets/xcsmask"));
			this.m.Stash.add(this.new("scripts/items/weapons/xcs_scimitar"));
			// this.m.Stash.add(this.new("scripts/items/weapons/xcs_greatsword"));
		}
	});


	// ==========================================
	// 劫持独狼开局场景：注入狂暴技能及初始资产
	// ==========================================
	::mods_hookExactClass("scenarios/world/lone_wolf_scenario", function(o) 
	{
		// 覆写队伍与资产初始化函数
		o.onSpawnAssets = function()
		{
			local roster = this.World.getPlayerRoster();
			local bro;
			bro = roster.create("scripts/entity/tactical/player");
			
			// [可修改点] 角色背景，决定了各种初始基础数值的浮动范围
			bro.setStartValuesEx([
				"hedge_knight_background"
			]);
			bro.getBackground().m.RawDescription = "A wandering hedge knight, you were a veteran of jousting and sparring tournaments. You were also a veteran of victory. Tis a scary thought for many, but if it were anything at all that turned your eye toward mercenary work it was boredom. Outwardly you state it is for the coin, but a part of you knows it\'s also for the company.";
			bro.getBackground().buildDescription(true);
			bro.setTitle("the Lone Wolf");
			
			// [可修改点] 移除不需要的特质
			bro.getSkills().removeByID("trait.survivor");
			bro.getSkills().removeByID("trait.greedy");
			bro.getSkills().removeByID("trait.loyal");
			bro.getSkills().removeByID("trait.disloyal");
			
			// 赋予玩家主角专属特质（判定战役失败的关键）
			bro.getSkills().add(this.new("scripts/skills/traits/player_character_trait"));
			
			// ==========================================
			// 核心修改：为独狼赋予兽人狂战士效果 加了会导致editor不能识别特质从而失效。
			// ==========================================
			// bro.getSkills().add(this.new("scripts/skills/effects/berserker_rage_effect"));

			bro.setPlaceInFormation(4);
			bro.getFlags().set("IsPlayerCharacter", true);
			bro.getSprite("miniboss").setBrush("bust_miniboss_lone_wolf");
			bro.m.HireTime = this.Time.getVirtualTimeF();
			
			// [可修改点] 初始天赋点数、升级次数与初始等级
			bro.m.PerkPoints = 3;
			bro.m.LevelUps = 3;
			bro.m.Level = 4;
			
			// [可修改点] 基础属性调整（原版在这里将对冲背景带来的属性，近战防御强制减2）
			bro.getBaseProperties().MeleeDefense += 5;
			
			bro.m.Talents = [];
			bro.m.Attributes = [];
			local talents = bro.getTalents();
			talents.resize(this.Const.Attributes.COUNT, 0);
			
			// [可修改点] 初始星星（天赋）分布 (1 = 1星, 2 = 2星, 3 = 3星)
			// 你可以更改下面这三个，或者新增比如 talents[this.Const.Attributes.Hitpoints] = 3
			talents[this.Const.Attributes.MeleeDefense] = 3;
			talents[this.Const.Attributes.Fatigue] = 3;
			talents[this.Const.Attributes.MeleeSkill] = 3;
			talents[this.Const.Attributes.RangedDefense] = 3;
			talents[this.Const.Attributes.Initiative] = 3;
			talents[this.Const.Attributes.Hitpoints] = 3;

			bro.fillAttributeLevelUpValues(this.Const.XP.MaxLevelWithPerkpoints - 1);
			local items = bro.getItems();
			items.unequip(items.getItemAtSlot(this.Const.ItemSlot.Body));
			items.unequip(items.getItemAtSlot(this.Const.ItemSlot.Head));
			items.unequip(items.getItemAtSlot(this.Const.ItemSlot.Mainhand));
			items.unequip(items.getItemAtSlot(this.Const.ItemSlot.Offhand));
			
			// [可修改点] 初始装备（强烈建议：把之前做好的 xcsmask 和 xcs_greatsword 路径填到这里）不要加 加了会报错
			items.equip(this.new("scripts/items/armor/sellsword_armor"));
			items.equip(this.new("scripts/items/helmets/bascinet_with_mail"));
			items.equip(this.new("scripts/items/weapons/longsword"));
			
			// [可修改点] 初始商队声望
			this.World.Assets.m.BusinessReputation = 200;
			
			// [可修改点] 储物箱容量惩罚（独狼原版背包格子少9个，把这行注释掉即可恢复正常容量）
			this.World.Assets.getStash().resize(this.World.Assets.getStash().getCapacity() + 29);
			
			// [可修改点] 初始背包物资
			this.World.Assets.getStash().add(this.new("scripts/items/supplies/smoked_ham_item"));
			
			// [可修改点] 初始资金、护甲零件、医疗工具与弹药储备
			// 原版独狼的物资是根据经济难度除以2或3的，你可以直接改成 this.World.Assets.m.Money = 5000;
			this.World.Assets.m.Money = 50000;
			this.World.Assets.m.ArmorParts = this.World.Assets.m.ArmorParts / 2;
			this.World.Assets.m.Medicine = this.World.Assets.m.Medicine / 3;
			this.World.Assets.m.Ammo = 0;
		}


	// [可修改点] GlobalMinDelay: 两次事件之间的绝对最小冷却时间（单位：游戏内流逝的秒数）。原值：240.0。
	// 原理解析：当一个事件结束后，系统必须等待此时间归零才会进入下一次判定池。将其调低（如 120.0 或 60.0）可大幅缩短两次事件间的强制静默期。
	::Const.Events.GlobalMinDelay = 80.0;
	
	// [可修改点] GlobalBaseChance: 冷却期结束时的初始触发概率基数。原值：1.0。
	// 原理解析：当 GlobalMinDelay 倒计时结束的那一刻，系统赋予的基础触发权重。通常保持原值即可；若需在冷却期结束后瞬间极大概率触发事件，可将其调高。
	::Const.Events.GlobalBaseChance = 1.5;
	
	// [可修改点] GlobalChancePerSecond: 冷却期结束后，每秒递增的触发概率权重。
	// 原值：0.21。
	// 原理解析：随着大地图时间流逝，触发概率会基于此数值不断累加，直到满足条件抛出事件。调高此值（如 0.50 或 1.0）会使得系统在度过静默期后，极为迅速地达到必定触发的阈值。
	::Const.Events.GlobalChancePerSecond = 1.50;
	
	// [底层引擎参数] AllottedTimePerEvaluationRun: 每次事件评估循环允许占用的最大CPU运算时间（单位：秒）。
	// 原值：0.001。
	// 原理解析：这是一个性能保护机制。由于游戏后期事件池极大，系统在后台遍历所有事件以判定哪些事件满足触发条件时，可能会产生瞬时运算量。限制在 0.001 秒可防止游戏主线程出现卡顿（掉帧）。通常不建议修改，除非你加载了大量巨型 Mod 导致事件判定超时丢失。
	::Const.Events.AllottedTimePerEvaluationRun = 0.001;
	
	});

	// ==========================================
	// 4. 全局经济修改：提高任务报酬与售卖利润
	// ==========================================

	// --- 提高所有合约（任务）的报酬 ---
	::mods_hookExactClass("contracts/contract", function(o) 
	{
		// 拦截合约基类的报酬倍率计算器
		local getPaymentMult_original = o.getPaymentMult;
		o.getPaymentMult = function()
		{
			// 原版机制：根据战团当前的声望（Renown）和经济难度，计算出一个基础倍率。
			// 修改逻辑：在原版结算结果的基础上，强制乘以 1.5。
			// 效果：全图所有任务（无论是村长给的还是贵族给的）的报酬直接提高 50%。
			// [可修改点]：若需更高报酬，可将 1.5 改为 2.0 或 3.0。
			return getPaymentMult_original() * 1.5; 
		}
	});

	// --- 提高全图城镇的售卖利润 ---
	::mods_hookExactClass("states/world/asset_manager", function(o) 
	{
		local getSellPriceMult_original = o.getSellPriceMult;
		o.getSellPriceMult = function()
		{
			// 原版机制：BB 的经济系统极其苛刻，通常你卖出装备的价格只有其面板价值的 15% 到 20% 左右（受城镇状态影响）。修改逻辑：在最终卖出倍率上强制乘以 2.0。
			return getSellPriceMult_original() * 1.5; 
		}
	});

})