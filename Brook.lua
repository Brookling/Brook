--- STEAMODDED HEADER
--- MOD_NAME: Brook
--- MOD_ID: Brook
--- MOD_AUTHOR: [Brookling BaiMao]
--- MOD_DESCRIPTION: Add 15 vanilla-like Jokers
--- BADGE_COLOUR: EACCD2
--- PREFIX: broo
--- VERSION: 1.0.2
----------------------------------------------
------------MOD CODE -------------------------

SMODS.current_mod.description_loc_vars = function()
    return {background_colour = G.C.CLEAR, text_colour = G.C.WHITE, scale = 1.2, shadow = true}
end

SMODS.current_mod.custom_ui = function(nodes)
    local _, description = unpack(nodes)
    local wiki_deepfind = SMODS.deepfind(description, "https://balatromods.miraheze.org/wiki/Brook", true)[1]
    if wiki_deepfind then
        local wiki_link_table = wiki_deepfind.objtree[#wiki_deepfind.objtree-2]
        wiki_link_table.config.button = "open_brook_wiki"
        wiki_link_table.config.tooltip = {text = {localize("b_open_brook_wiki")}}
    end
end

G.FUNCS.open_brook_wiki = function(e)
    love.system.openURL("https://balatromods.miraheze.org/wiki/Brook")
end

SMODS.current_mod.extra_tabs = function()
    local nodes = {}
    localize{type = 'descriptions', key = 'About', set = 'Mod', nodes = nodes, scale = 1.2, text_colour = G.C.WHITE, shadow = true}
    nodes = desc_from_rows(nodes)
    nodes.config.colour = G.C.CLEAR
    return {
        label = localize('b_brookling_about'),
        tab_definition_function = function()
            return {n=G.UIT.ROOT, config = {emboss = 0.05, minh = 6, r = 0.1, minw = 6, align = "cm", padding = 0.2, colour = G.C.BLACK}, nodes={
                nodes
            }}
        end
    }
end

local function find_highest_suit()
    local highest_suit = nil
    local highest_count = 0
    local suit_conversion = {}
    local tied_for_highest = false
    for _, v in ipairs(G.playing_cards) do
        if v.ability.effect ~= 'Stone Card' and not (v.config.center.no_suit) then
            suit_conversion[v.base.suit] = (suit_conversion[v.base.suit] or 0) + 1
        end
    end
    for k, v in pairs(suit_conversion) do
        if v > highest_count then
            highest_suit = k
            highest_count = v
        end
    end
    for k, v in pairs(suit_conversion) do
        if v == highest_count and k ~= highest_suit then
            tied_for_highest = true
            break
        end
    end
    if tied_for_highest and suit_conversion["Spades"] and suit_conversion["Spades"] == highest_count then
        return "Spades"
    end
    return highest_suit or "Spades"
end

local function get_pack_key(list, _key)
    local cume, it, center = 0, 0, nil
    for k, v in ipairs(list) do
        cume = cume + (G.P_CENTERS[v].weight or 1)
    end
    local poll = pseudorandom(_key or 'gpk')*cume
    for k, v in ipairs(list) do
        it = it + (G.P_CENTERS[v].weight or 1)
        if it >= poll and it - (v.weight or 1) <= poll then
            center = v
            break
        end
    end
    return center or "p_arcana_normal_1"
end

local get_pack_ref = get_pack
function get_pack(_key, _type)
    if G.GAME.check_chris and G.GAME.check_chris >= 1 then
        G.GAME.check_chris = G.GAME.check_chris - 1
        local list = {"p_spectral_mega_1", "p_buffoon_mega_1"}
        local chris = get_pack_key(list, 'christmas')
        return G.P_CENTERS[chris]
    end
    return get_pack_ref(_key, _type)
end

local Card_update_ref = Card.update
function Card:update(dt)
    Card_update_ref(self, dt)
    if G.STAGE == G.STAGES.RUN then
        if self.ability.name == 'Ink' then
            local ink_suit = find_highest_suit()
            for k, v in pairs(G.P_CENTERS) do
                if v.config and v.config.suit_conv and v.config.suit_conv == ink_suit then
                    self.ability.extra.ink_tarot = k
                    break
                end
            end
        end
        if self.ability.name == 'D4C' then
            self.ability.extra.eligible_d4c_jokers = {}
            for k, v in pairs(G.jokers.cards) do
                if v.ability.set == 'Joker' and (not v.edition) and v.ability.name ~= 'D4C' then
                    table.insert(self.ability.extra.eligible_d4c_jokers, v)
                end
            end
        end
    end
end

local draw_card_ref = draw_card
function draw_card(from, to, percent, dir, sort, card, delay, mute, stay_flipped, vol, discarded_only)
    if from == G.hand and to == G.discard and card then
        if next(find_joker("Pulp Fiction")) and (card:get_id() == 2 or card:get_id() == 3 or card:get_id() == 4 or card:get_id() == 5) then
            card.ability.pulp = true
        end
    end
    draw_card_ref(from, to, percent, dir, sort, card, delay, mute, stay_flipped, vol, discarded_only)
end

G.FUNCS.draw_from_discard_to_deck = function(e)
    G.E_MANAGER:add_event(Event({trigger = 'immediate', func = function()
        local discard_count = #G.discard.cards
        for i = 1, discard_count do
            if not G.discard.cards[i].ability.pulp then
                draw_card(G.discard, G.deck, i*100/discard_count, 'up', nil, G.discard.cards[i], 0.005, i%2==0, nil, math.max((21-i)/20,0.7))
            end
        end
    return true end}))
end

local G_FUNCS_deck_info_ref = G.FUNCS.deck_info
G.FUNCS.deck_info = function(e)
    G.SETTINGS.paused = true
    if G.deck_preview then 
        G.deck_preview:remove()
        G.deck_preview = nil
    end
    local _show_remaining = nil
    if #G.deck.cards < #G.playing_cards then _show_remaining = true end
    G.FUNCS.overlay_menu{
        definition = G.UIDEF.deck_info(_show_remaining),
    }
end

local add_round_eval_row_ref = add_round_eval_row
function add_round_eval_row(config)
    add_round_eval_row_ref(config)
    if config.name == 'interest' then
        SMODS.calculate_context({interest = config.dollars, eval_interest = true})
    end
end

local CardArea_update_ref = CardArea.update
function CardArea:update(dt)
    CardArea_update_ref(self, dt)
    if self == G.deck and self.config.card_limit ~= #G.playing_cards then self.config.card_limit = #G.playing_cards end
end

-- Talisman Compat
to_big = to_big or function(a)
    return a
end

SMODS.Atlas{
    key = "modicon",
    px = 34,
    py = 34,
    path = "icon.png"
}

SMODS.Atlas{
    key = 'jokers',
    px = 71,
    py = 95,
    path = 'jokers.png'
}

SMODS.Joker{
    key = 'stargaze',
    name = 'Stargaze',
    rarity = 1,
    cost = 6,
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    eternal_compat = false,
    perishable_compat = true,
    pos = { x = 0, y = 0 },
    loc_txt ={},
    atlas = 'jokers',
    config = { extra = {gaze_hand = "High Card", gaze_bonus = 3} },
    loc_vars = function(self, info_queue, card)
        return { vars = {localize(card.ability.extra.gaze_hand, 'poker_hands'), card.ability.extra.gaze_bonus} }
    end,
    set_ability = function(self, card, minitial, delay_sprites)
        local gaze_hands = {}
        for k, v in pairs(G.GAME.hands) do
            if v.visible then
                gaze_hands[#gaze_hands + 1] = k
            end
        end
        card.ability.extra.gaze_hand = pseudorandom_element(gaze_hands, pseudoseed('gaz'))
    end,
    calculate = function(self, card, context)
        if context.after and not context.blueprint then
            local gaze_hands = {}
            for k, v in pairs(G.GAME.hands) do
                if v.visible and k ~= card.ability.extra.gaze_hand then
                    gaze_hands[#gaze_hands + 1] = k
                end
            end
            G.E_MANAGER:add_event(Event({func = function()
                card.ability.extra.gaze_hand = pseudorandom_element(gaze_hands, pseudoseed('gaz'))
            return true end}))
            card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_reset')})
        end
        if context.selling_self then
            card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, {message = localize('k_upgrade_ex')})
            update_hand_text({sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3}, {handname = localize(card.ability.extra.gaze_hand, 'poker_hands'), chips = G.GAME.hands[card.ability.extra.gaze_hand].chips, mult = G.GAME.hands[card.ability.extra.gaze_hand].mult, level = G.GAME.hands[card.ability.extra.gaze_hand].level})
            level_up_hand(context.blueprint_card or card, card.ability.extra.gaze_hand, nil, card.ability.extra.gaze_bonus)
            update_hand_text({sound = 'button', volume = 0.7, pitch = 1.1, delay = 0}, {mult = 0, chips = 0, handname = '', level = ''})
        end
    end
}

SMODS.Joker{
    key = 'ink',
    name = 'Ink',
    rarity = 2,
    cost = 7,
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    pos = { x = 1, y = 0 },
    loc_txt ={},
    atlas = 'jokers',
    config = { extra = {ink_tarot = "c_world"} },
    loc_vars = function(self, info_queue, card)
        local main_end
        local ink_c = card.ability.extra.ink_tarot and G.P_CENTERS[card.ability.extra.ink_tarot]
        local ink_tarot = ink_c and localize{type = 'name_text', key = ink_c.key, set = ink_c.set}
        local colour = G.C.SUITS[ink_c.config.suit_conv]
        if card.area and card.area == G.jokers then
            main_end = {
                {n=G.UIT.C, config={align = "bm", padding = 0.02}, nodes={
                    {n=G.UIT.C, config={align = "m", colour = colour, r = 0.05, padding = 0.05}, nodes={
                        {n=G.UIT.T, config={text = ' '..ink_tarot..' ', colour = G.C.UI.TEXT_LIGHT, scale = 0.3, shadow = true}},
                    }}
                }}
            }
        end
        return { vars = {}, main_end = main_end }
    end,
    calculate = function(self, card, context)
        if context.setting_blind and not (context.blueprint_card or card).getting_sliced and #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
            G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
            G.E_MANAGER:add_event(Event({func = function()
                local _card = create_card('Tarot', G.consumeables, nil, nil, nil, nil, card.ability.extra.ink_tarot, 'ink')
                _card:add_to_deck()
                G.consumeables:emplace(_card)
                G.GAME.consumeable_buffer = 0
            return true end}))
            card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, {message = localize('k_plus_tarot'), colour = G.C.PURPLE})
        end
    end
}

SMODS.Joker{
    key = 'd4c',
    name = 'D4C',
    rarity = 2,
    cost = 8,
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    pos = { x = 2, y = 0 },
    loc_txt ={},
    atlas = 'jokers',
    config = { extra = {eligible_d4c_jokers = {}} },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.e_foil
        return { vars = {} }
    end,
    calculate = function(self, card, context)
        if context.ending_shop and next(card.ability.extra.eligible_d4c_jokers) then
            local eligible_d4c_joker, eligible_d4c_joker_key = pseudorandom_element(card.ability.extra.eligible_d4c_jokers, pseudoseed('d4c'))
            table.remove(card.ability.extra.eligible_d4c_jokers, eligible_d4c_joker_key)
            G.E_MANAGER:add_event(Event({func = function()
                eligible_d4c_joker:set_edition({foil = true}, true)
            return true end}))
            card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, {message = localize('k_d4c')})
        end
    end
}

SMODS.Joker{
    key = 'christmas_card',
    name = 'Christmas Card',
    rarity = 2,
    cost = 8,
    unlocked = true,
    discovered = true,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,
    pos = { x = 3, y = 0 },
    loc_txt ={},
    atlas = 'jokers',
    config = { extra = {packs = 1} },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_CENTERS.p_buffoon_mega_1
        info_queue[#info_queue+1] = G.P_CENTERS.p_spectral_mega_1
        return { vars = {} }
    end,
    add_to_deck = function(self, card, from_debuff)
        G.GAME.starting_params.boosters_in_shop = G.GAME.starting_params.boosters_in_shop + 1
    end,
    remove_from_deck = function(self, card, from_debuff)
        G.GAME.starting_params.boosters_in_shop = G.GAME.starting_params.boosters_in_shop - 1
    end,
    calculate = function(self, card, context)
        if context.end_of_round and not context.individual and not context.repetition and not context.blueprint then
            G.GAME.check_chris = (G.GAME.check_chris or 0) + 1
        end
    end
}

SMODS.Joker{
    key = 'trace',
    name = 'Trace',
    rarity = 1,
    cost = 4,
    unlocked = true,
    discovered = true,
    blueprint_compat = false,
    eternal_compat = false,
    perishable_compat = true,
    pos = { x = 4, y = 0 },
    loc_txt ={},
    atlas = 'jokers',
    config = { extra = {odd = 4, dollars = 20} },
    no_pool_flag = 'trace_extinct',
    loc_vars = function(self, info_queue, card)
        return { vars = {''..(G.GAME and G.GAME.probabilities.normal or 1), card.ability.extra.odd, card.ability.extra.dollars} }
    end,
    calculate = function(self, card, context)
        if context.end_of_round and not context.individual and not context.repetition and not context.blueprint then
            if pseudorandom('trace') < G.GAME.probabilities.normal/card.ability.extra.odd then
                G.GAME.pool_flags.trace_extinct = true
                ease_dollars(card.ability.extra.dollars)
                G.E_MANAGER:add_event(Event({func = function()
                    play_sound('tarot1')
                    card.T.r = -0.2
                    card:juice_up(0.3, 0.4)
                    card.states.drag.is = true
                    card.children.center.pinch.x = true
                    G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, blockable = false, func = function()
                        G.jokers:remove_card(card)
                        card:remove()
                        card = nil
                    return true end}))
                return true end}))
                return {
                    message = localize('$')..card.ability.extra.dollars,
                    colour = G.C.MONEY,
                    card = card
                }
            else
                return {
                    message = localize('k_nope_ex'),
                    card = card
                }
            end
        end
    end
}

SMODS.Joker{
    key = 'cattail',
    name = 'Cattail',
    rarity = 1,
    cost = 4,
    unlocked = true,
    discovered = true,
    blueprint_compat = false,
    eternal_compat = false,
    perishable_compat = true,
    pos = { x = 0, y = 1 },
    loc_txt ={},
    atlas = 'jokers',
    config = { extra = {destroyed_quantity = 5} },
    loc_vars = function(self, info_queue, card)
        return { vars = {card.ability.extra.destroyed_quantity} }
    end,
    calculate = function(self, card, context)
        if context.destroying_card and not context.blueprint and card.ability.extra.destroyed_quantity >= 1 then
            card.ability.extra.destroyed_quantity = card.ability.extra.destroyed_quantity - 1
            local scoring_hand = context.scoring_hand
            if context.destroying_card == scoring_hand[#scoring_hand] or card.ability.extra.destroyed_quantity <= 0 then
                card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_burnt_out'), colour = G.C.RED})
            end
            if card.ability.extra.destroyed_quantity <= 0 then
                G.E_MANAGER:add_event(Event({func = function()
                    play_sound('tarot1')
                    card.T.r = -0.2
                    card:juice_up(0.3, 0.4)
                    card.states.drag.is = true
                    card.children.center.pinch.x = true
                    G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, blockable = false, func = function()
                        G.jokers:remove_card(card)
                        card:remove()
                        card = nil
                    return true end}))
                return true end}))
            end
            return true
        end
    end
}

SMODS.Joker{
    key = 'yeast',
    name = 'Yeast',
    rarity = 2,
    cost = 6,
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = false,
    pos = { x = 1, y = 1 },
    loc_txt ={},
    atlas = 'jokers',
    config = { extra = {x_mult = 0.1, gains = 0.1, increase = 0.1} },
    loc_vars = function(self, info_queue, card)
        return { vars = {card.ability.extra.x_mult, card.ability.extra.gains, card.ability.extra.increase} }
    end,
    calculate = function(self, card, context)
        if context.cardarea == G.jokers and context.end_of_round and not context.blueprint then
            if G.GAME.blind.boss then
                card.ability.extra.gains = card.ability.extra.gains + card.ability.extra.increase
            end
            card.ability.extra.x_mult = card.ability.extra.x_mult + card.ability.extra.gains
            card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_upgrade_ex'), colour = G.C.MULT})
        end
        if context.joker_main and card.ability.extra.x_mult ~= 1 then
            return {
                message = localize{type='variable',key='a_xmult',vars={card.ability.extra.x_mult}},
                Xmult_mod = card.ability.extra.x_mult,
            }
        end
    end
}

SMODS.Joker{
    key = 'unease',
    name = 'Unease',
    rarity = 2,
    cost = 8,
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    pos = { x = 2, y = 1 },
    loc_txt ={},
    atlas = 'jokers',
    config = { extra = {mult_mod = 28} },
    loc_vars = function(self, info_queue, card)
        return { vars = {card.ability.extra.mult_mod} }
    end,
    calculate = function(self, card, context)
        if context.before then
            local text = context.scoring_name
            G.GAME.hands[text].s_mult = G.GAME.hands[text].s_mult + card.ability.extra.mult_mod
            G.GAME.hands[text].mult = G.GAME.hands[text].mult + card.ability.extra.mult_mod
            mult = mod_mult(G.GAME.hands[text].mult)
            update_hand_text({delay = 0}, {chips = hand_chips, mult = mult})
            card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, {message = localize{type = 'variable', key = 'a_mult', vars = {card.ability.extra.mult_mod}}, colour = G.C.MULT, sound = 'multhit1'})
        end
        if context.after then
            local text = context.scoring_name
            G.GAME.hands[text].s_mult = G.GAME.hands[text].s_mult - card.ability.extra.mult_mod
            G.GAME.hands[text].mult = G.GAME.hands[text].mult - card.ability.extra.mult_mod
        end
    end
}

SMODS.Joker{
    key = 'alien',
    name = 'Alien',
    rarity = 3,
    cost = 9,
    unlocked = true,
    discovered = true,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,
    pos = { x = 3, y = 1 },
    loc_txt ={},
    atlas = 'jokers',
    config = { extra = {max = 5, min = 2, current_rerolls = 0} },
    loc_vars = function(self, info_queue, card)
        local main_end
        local r_rerolls = {}
        for i = card.ability.extra.min, card.ability.extra.max do
            r_rerolls[#r_rerolls+1] = ' '..tostring(i)
        end
        local loc_reroll = localize('k_free_reroll_2')..' '
        main_end = {
            {n=G.UIT.O, config={object = DynaText({string = r_rerolls, colours = {G.C.FILTER}, pop_in_rate = 9999999, silent = true, random_element = true, pop_delay = 0.5, scale = 0.32, min_cycle_time = 0})}},
            {n=G.UIT.T, config={text = ' '..(localize('k_free_reroll_1'))..' ',colour = G.C.UI.TEXT_DARK, scale = 0.32}},
            {n=G.UIT.O, config={object = DynaText({string = {
                {string = 'rand()', colour = G.C.JOKER_GREY},{string = "#@"..(G.deck and G.deck.cards[1] and G.deck.cards[#G.deck.cards].base.id or 11)..(G.deck and G.deck.cards[1] and G.deck.cards[#G.deck.cards].base.suit:sub(1,1) or 'D'), colour = G.C.RED},
                loc_reroll, loc_reroll, loc_reroll, loc_reroll, loc_reroll, loc_reroll, loc_reroll, loc_reroll, loc_reroll, loc_reroll, loc_reroll, loc_reroll, loc_reroll},
            colours = {G.C.GREEN},pop_in_rate = 9999999, silent = true, random_element = true, pop_delay = 0.2011, scale = 0.32, min_cycle_time = 0})}},
        }
        return { vars = {}, main_end = main_end }
    end,
    add_to_deck = function(self, card, from_debuff)
        local temp_free_rerolls = pseudorandom('alien', card.ability.extra.min, card.ability.extra.max)
        card.ability.extra.current_rerolls = temp_free_rerolls
        G.GAME.current_round.free_rerolls = math.max(G.GAME.current_round.free_rerolls + temp_free_rerolls, 0)
        calculate_reroll_cost(true)
    end,
    remove_from_deck = function(self, card, from_debuff)
        if card.ability.extra.current_rerolls >= 1 then
            G.GAME.current_round.free_rerolls = math.max(G.GAME.current_round.free_rerolls - card.ability.extra.current_rerolls, 0)
            calculate_reroll_cost(true)
        end
    end,
    calculate = function(self, card, context)
        if context.starting_shop and card.ability.extra.current_rerolls <= 0 and not context.blueprint then
            local temp_free_rerolls = pseudorandom('alien', card.ability.extra.min, card.ability.extra.max)
            card.ability.extra.current_rerolls = temp_free_rerolls
            G.GAME.current_round.free_rerolls = math.max(G.GAME.current_round.free_rerolls + temp_free_rerolls, 0)
            calculate_reroll_cost(true)
        end
        if context.ending_shop and not context.blueprint then
            card.ability.extra.current_rerolls = 0
        end
    end
}

SMODS.Joker{
    key = 'needle_thread',
    name = 'Needle_Thread',
    rarity = 1,
    cost = 5,
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    pos = { x = 4, y = 1 },
    loc_txt ={},
    atlas = 'jokers',
    config = { extra = {} },
    loc_vars = function(self, info_queue, card)
        return { vars = {} }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local chips = math.floor(hand_chips)
            local units = chips%10
            local tens = math.floor(chips/10)%10
            local filling = 100 - (tens*10 + units)
            return {
                message = localize{type='variable',key='a_chips',vars={filling}},
                chip_mod = filling, 
                colour = G.C.CHIPS
            }
        end
    end
}

SMODS.Joker{
    key = 'dancer',
    name = 'Dancer',
    rarity = 3,
    cost = 7,
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    pos = { x = 0, y = 2 },
    loc_txt ={},
    atlas = 'jokers',
    config = { extra = {repetition = 1} },
    loc_vars = function(self, info_queue, card)
        return { vars = {card.ability.extra.repetition} }
    end,
    calculate = function(self, card, context)
        if context.repetition and (#G.jokers.cards + G.GAME.joker_buffer < G.jokers.config.card_limit) then
            if (context.cardarea == G.hand and (next(context.card_effects[1]) or #context.card_effects > 1)) or context.cardarea == G.play then
                return {
                    message = localize('k_again_ex'),
                    repetitions = card.ability.extra.repetition,
                    card = card
                }
            end
        end
    end
}

SMODS.Joker{
    key = 'pulp_fiction',
    name = 'Pulp Fiction',
    rarity = 3,
    cost = 7,
    unlocked = true,
    discovered = true,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,
    pos = { x = 1, y = 2 },
    loc_txt ={},
    atlas = 'jokers',
    config = { extra = {} },
    loc_vars = function(self, info_queue, card)
        return { vars = {} }
    end,
    remove_from_deck = function(self, card, from_debuff)
        G.E_MANAGER:add_event(Event({trigger = 'immediate', func = function()
            local discard_count = #G.discard.cards
            for i = 1, discard_count do
                if G.discard.cards[i].ability.pulp then
                    G.discard.cards[i].ability.pulp = nil
                    draw_card(G.discard, G.deck, i*100/discard_count, 'up', nil, G.discard.cards[i], 0.005, i%2==0, nil, math.max((21-i)/20,0.7))
                end
            end
        return true end}))
    end,
    calculate = function(self, card, context)
    end
}

SMODS.Joker{
    key = 'parrot',
    name = 'Parrot',
    rarity = 2,
    cost = 7,
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    pos = { x = 2, y = 2 },
    loc_txt ={},
    atlas = 'jokers',
    config = { extra = {tags = 1} },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = {key = 'tag_voucher', set = 'Tag'}
        return { vars = {card.ability.extra.tags} }
    end,
    calculate = function(self, card, context)
        if context.end_of_round and not context.individual and not context.repetition then
            G.E_MANAGER:add_event(Event({func = (function()
                add_tag(Tag('tag_voucher'))
                play_sound('generic1', 0.9 + math.random()*0.1, 0.8)
                play_sound('holo1', 1.2 + math.random()*0.1, 0.4)
                return true
            end)}))
            card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, {message = localize('k_plus_tag')})
        end
    end
}

SMODS.Joker{
    key = 'moon_rabbit',
    name = 'Moon Rabbit',
    rarity = 2,
    cost = 6,
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = false,
    pos = { x = 3, y = 2 },
    loc_txt ={},
    atlas = 'jokers',
    config = { extra = {interest_target = 8, interest_current = 0, x_mult = 1, x_mult_mod = 0.2} },
    loc_vars = function(self, info_queue, card)
        return { vars = {card.ability.extra.interest_target, card.ability.extra.interest_current, card.ability.extra.x_mult, card.ability.extra.x_mult_mod} }
    end,
    calculate = function(self, card, context)
        if context.eval_interest and not context.blueprint then
            if to_big(context.interest) >= to_big(1) then
                local interest = to_big(context.interest) + to_big(card.ability.extra.interest_current)
                local quotient = math.floor(interest/to_big(card.ability.extra.interest_target))
                local remainder = interest%to_big(card.ability.extra.interest_target)
                card.ability.extra.interest_current = remainder
                if to_big(quotient) >= to_big(1) then
                    card.ability.extra.x_mult = card.ability.extra.x_mult + card.ability.extra.x_mult_mod*to_big(quotient)
                    G.E_MANAGER:add_event(Event({func = function()
                        card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize{type='variable',key='a_xmult',vars={card.ability.extra.x_mult}}})
                    return true end}))
                end
            end
        end
        if context.joker_main and card.ability.extra.x_mult > 1 then
            return {
                message = localize{type='variable',key='a_xmult',vars={card.ability.extra.x_mult}},
                Xmult_mod = card.ability.extra.x_mult
            }
        end
    end
}

SMODS.Joker{
    key = 'baby_dinosaur',
    name = 'Baby Dinosaur',
    rarity = 1,
    cost = 4,
    unlocked = true,
    discovered = true,
    blueprint_compat = false,
    eternal_compat = false,
    perishable_compat = true,
    pos = { x = 4, y = 2 },
    loc_txt ={},
    atlas = 'jokers',
    config = { extra = {ante_mod = 1} },
    yes_pool_flag = 'trace_extinct',
    no_pool_flag = 'baby_dinosaur_extinct',
    loc_vars = function(self, info_queue, card)
        return { vars = {card.ability.extra.ante_mod} }
    end,
    calculate = function(self, card, context)
        if context.end_of_round and not context.individual and not context.repetition and not context.blueprint and not G.GAME.blind.boss then
            G.GAME.pool_flags.baby_dinosaur_extinct = true
            ease_ante(-card.ability.extra.ante_mod)
            G.GAME.round_resets.blind_ante = G.GAME.round_resets.blind_ante or G.GAME.round_resets.ante
            G.GAME.round_resets.blind_ante = G.GAME.round_resets.blind_ante - card.ability.extra.ante_mod
            G.E_MANAGER:add_event(Event({func = function()
                play_sound('tarot1')
                card.T.r = -0.2
                card:juice_up(0.3, 0.4)
                card.states.drag.is = true
                card.children.center.pinch.x = true
                G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, blockable = false, func = function()
                    G.jokers:remove_card(card)
                    card:remove()
                    card = nil
                return true end}))
            return true end}))
            return {
                message = localize('k_rewind'),
                colour = G.C.RED
            }
        end
    end
}

----------------------------------------------
------------MOD CODE END----------------------
