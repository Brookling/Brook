return {
    descriptions = {
        Joker={
            j_broo_stargaze={
                name = '观星',
                text = {
                    "售出此牌以提升{C:attention}#1#{}",
                    "{C:attention}#2#个等级{}",
                    "每次出牌后都改变牌型",
                },
            },
            j_broo_d4c={
                name = 'D4C',
                text = {
                    "离开商店时",
                    "给一张随机{C:attention}小丑牌",
                    "添加{C:dark_edition}闪箔{}版本",
                    "不再赚取{C:attention}利息{}",
                },
            },
            j_broo_ink={
                name = '油墨',
                text = {
                    "在选择{C:attention}盲注{}时",
                    "生成一张与牌组中",
                    "数量{C:attention}最多{}的花色",
                    "对应的{C:tarot}塔罗牌{}",
                    "{C:inactive}（必须有空位）",
                },
            },
            j_broo_occultist={
                name = '神秘学家',
                text = {
                    "交换商店中{C:attention}标准包{}",
                    "与{C:spectral}幻灵包{}的出现频率",
                },
            },
            j_broo_trace={
                name = '追踪',
                text = {
                    "回合结束时",
                    "有{C:green}#1#/#2#{}的几率",
                    "获得{C:money}$#3#{}并{S:1.1,C:red,E:2}自毁",
                },
            },
            j_broo_cattail={
                name = '香蒲',
                text = {
                    "摧毁接下来的",
                    "{C:attention}#1#{}张计分牌",
                },
            },
            j_broo_yeast={
                name = '酵母菌',
                text = {
                    "回合结束时",
                    "这张小丑牌获得{X:mult,C:white}X#2#{}倍率",
                    "击败{C:attention}Boss盲注{}",
                    "会使这一数值提高{X:mult,C:white}X#3#{}",
                    "{C:inactive}（当前为{X:mult,C:white}X#1#{C:inactive}倍率）",
                },
            },
            j_broo_unease={
                name = '不安感',
                text = {
                    "{C:mult}+#1#{}基础倍率",
                },
            },
            j_broo_alien={
                name = '外星人',
                text = {
                    "每个商店有",
                },
            },
            j_broo_needle_thread={
                name = '针与线',
                text = {
                    "将当前的{C:blue}筹码{}",
                    "补到下一个整百数",
                    "{C:inactive}（例如：25 -> 100）",
                },
            },
            j_broo_dancer={
                name = '舞姬',
                text = {
                    "若小丑牌槽位未满",
                    "重新触发所有{C:attention}游戏牌",
                },
            },
            j_broo_pulp_fiction={
                name = '低俗小说',
                text = {
                    "弃掉的{C:attention}2{}、{C:attention}3{}、{C:attention}4{}或{C:attention}5{}",
                    "不再返回{C:attention}牌组{}，直到",
                    "此牌被售出或摧毁",
                },
            },
            j_broo_parrot={
                name = '鹦鹉',
                text = {
                    "回合结束时",
                    "生成一个",
                    "{C:attention}优惠券标签",
                },
            },
            j_broo_moon_rabbit={
                name = '月兔',
                text = {
                    "每赚取{C:money}$#1#{C:inactive}[#2#]{}的{C:attention}利息",
                    "这张小丑牌获得{X:mult,C:white}X#4#{}倍率",
                    "{C:inactive}（当前为{X:mult,C:white}X#3#{C:inactive}倍率）",
                },
            },
            j_broo_baby_dinosaur={
                name = '恐龙宝贝',
                text = {
                    "在{C:attention}小盲注{}",
                    "或{C:attention}大盲注{}结束时",
                    "底注{C:attention}-#1#{}并{S:1.1,C:red,E:2}自毁",
                },
            },
        },
        Mod={
            Brook={
                name = "Brook",
                text = {
                    "添加{C:red}15{}张原版风格的新小丑",
                    " ",
                    "{C:dark_edition}设计&美术{}",
                    "小水怪",
                    " ",
                    "{C:gold}代码{}",
                    "白猫早睡",
                    " ",
                    "{C:green}感谢{}",
                    "柔雪似水，第八大洋，彼君不触，",
                    "海星只会玩模组，224六妖",
                    " ",
                    "点击浏览{C:blue}wiki{}页面：",
                    "{C:attention}https://balatromods.miraheze.org/wiki/Brook{}",
                }
            },
            About={
                name = "About",
                text = {
                    "朋友们好！我是小水怪。",
                    " ",
                    "自{C:attention}2024年2月{}小丑牌发售以来，我一直在玩这款游戏。",
                    "我非常喜欢它。我主要玩{C:money}金注{}连胜，最好成绩是{C:red}18{}连胜。",
                    " ",
                    "{C:attention}从2025年2月到8月{}，我一直致力于制作一款{C:blue}高质量的{}",
                    "{C:blue}香草{}模组。我从很多已有的模组汲取了灵感，非常感谢那些创作者。",
                    " ",
                    "我设计了{C:red}15{}张新小丑牌，能力各不相同，类型非常丰富。我花了",
                    "很多精力在{C:attention}平衡性{}、{C:red}趣味性{}和{C:blue}创新性{}上，并绘制了卡面。",
                    " ",
                    "{C:green}特别感谢{}白猫早睡为本项目编写代码，也感谢所有支持的朋友。",
                    "{C:dark_edition}Brook{}现已发布，欢迎试玩。",
                }
            },
        },
    },
    misc={
        dictionary={
            b_open_brook_wiki="在浏览器中打开",
            b_brookling_about="关于",
            b_brook_github="GitHub",
            b_brook_discord="Discord",
            k_d4c="容易！",
            k_free_reroll_1="次",
            k_free_reroll_2="免费重掷",
            k_plus_tag="+1标签",
            k_burnt_out="烧完了！",
            k_rewind="倒流！",
        },
    },
}