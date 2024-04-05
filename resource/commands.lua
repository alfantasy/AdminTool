cmd_massive = {

        -- ## Команды исключительно для OnLine # --

	-- ## Команды для выдачи бана ## --

	["ch"] = {
		cmd = "/iban",
		reason = "Исп. читерских скриптов/ПО",
		time = 7,
	}, 
	["pl"] = {
		cmd = "/ban",
		reason = "Плагиат ника администратора",
		time = 7,
	},
	["ob"] = {
		cmd = "/iban",
		reason = "Обход прошлого бана",
		time = 7,
	},
	["hl"] = {
		cmd = "/iban",
		reason = "Оск/Униж/Мат в хелпере",
		time = 3,
	},
	["menk"] = {
		cmd = "/iban",
		reason = "Ник с запр. словами",
		time = 7,
	},
	["gnck"] = {
		cmd = "/iban",
		reason = "Банда с нецензурной лексикой",
		time = 7,
	},
	["bnm"] = {
		cmd = "/iban",
		reason = "Неадекватное поведение",
		time = 7,
	},
	["nk"] = {
		cmd = "/ban",
		reason = "Ник с нецензурной лексикой",
		time = 7,
	},

	-- ## Команды для выдачи бана ## --


	-- ## Команды для выдачи мута в чате ## --

	["fd"] = {
		cmd = "/mute",
		reason = "Флуд/Спам",
		time = 120,
		multi = true,
	}, 
	["po"] = {
		cmd = "/mute",
		reason = "Попрошайничество",
		time = 120,
		multi = true,
	}, 
	["nm"] = {
		cmd = "/mute",
		reason = "Неадекватное поведение",
		time = 600,
		multi = true,
	},
	['m'] = {
		cmd = "/mute",
		reason = "Нецензурная лексика",
		time = 300,
	},
	['ok'] = {
		cmd = "/mute",
		reason = "Оскорбление/Унижение",
		time = 400,
	},
	['oa'] = {
		cmd = "/mute",
		reason = "Оск/Унижение адм",
		time = 2500,
	},
	['kl'] = {
		cmd = "/mute",
		reason = "Клевета на администрацию",
		time = 3000,
	},
	['up'] = {
		cmd = "/mute",
		reason = "Упоминание стор.проектов",
		time = 1000,
	},
	['or'] = {
		cmd = "/mute",
		reason = "Оскорбление/Упоминание родных",
		time = 5000,
	},
	['ia'] = {
		cmd = "/mute",
		reason = "Выдача себя за адм",
		time = 2500,
	},
	['rz'] = {
		cmd = "/mute",
		reason = "Розжиг межнац.розни",
		time = 5000,
	},
	['zs'] = {
		cmd = "/mute",
		reason = "Злоуп. символами",
		time = 600,
	},

	-- ## Команды для выдачи мута в чате## --

	-- ## Команды для выдачи мута за репорт ## --

	["cp"] = {
		cmd = "/rmute",
		reason = "Флуд/Оффтоп",
		time = 120,
		multi = true,
	}, 
	["rpo"] = {
		cmd = "/rmute",
		reason = "Попрошайничество",
		time = 120,
		multi = true,
	}, 
	["rnm"] = {
		cmd = "/rmute",
		reason = "Неадекватное поведение",
		time = 600,
		multi = true,
	},
	['rm'] = {
		cmd = "/rmute",
		reason = "Нецензурная лексика",
		time = 300,
	},
	['rok'] = {
		cmd = "/rmute",
		reason = "Оскорбление/Унижение",
		time = 400,
	},
	['roa'] = {
		cmd = "/rmute",
		reason = "Оск/Унижение адм",
		time = 2500,
	},
	['rkl'] = {
		cmd = "/rmute",
		reason = "Клевета на администрацию",
		time = 3000,
	},
	['rup'] = {
		cmd = "/rmute",
		reason = "Упоминание стор.проектов",
		time = 1000,
	},
	['ror'] = {
		cmd = "/rmute",
		reason = "Оскорбление/Упоминание родных",
		time = 5000,
	},
	['ria'] = {
		cmd = "/rmute",
		reason = "Выдача себя за адм",
		time = 2500,
	},
	['rrz'] = {
		cmd = "/rmute",
		reason = "Розжиг межнац.розни",
		time = 5000,
	},
	['rzs'] = {
		cmd = "/rmute",
		reason = "Злоуп. символами",
		time = 600,
	},

	-- ## Команды для выдачи мута за репорт ## --

	-- ## Команды для выдачи джайла ## -- 

	['sk'] = {
		cmd = "/jail",
		reason = "Spawn Kill",
		time = 300,
		multi = true,
	},
	['dz'] = {
		cmd = "/jail",
		reason = "DM/DB in ZZ",
		time = 300,
		multi = true,
	},
	['td'] = {
		cmd = "/jail",
		reason = "Car in /trade",
		time = 300,
	},
	['jm'] = {
		cmd = "/jail",
		reason = "Нарушение правил MP",
		time = 300,
		multi = true,
	},
	['pmx'] = {
		cmd = "/jail",
		reason = "Серьезная помеха игрокам",
		time = 3000,
	},
	['skw'] = {
		cmd = "/jail",
		reason = "Spawn Kill in /gw",
		time = 600,
	},
	['dgw'] = {
		cmd = "/jail",
		reason = "Nark in /gw",
		time = 500,
	},
	['ngw'] = {
		cmd = "/jail",
		reason = "Invalid CMD in /gw",
		time = 600,
	},
	['dbgw'] = {
		cmd = "/jail",
		reason = "Helicopter in /gw",
		time = 600,
	},
	['fsh'] = {
		cmd = "/jail",
		reason = "SpeedHack/FlyCar",
		time = 900,
	},
	['bag'] = {
		cmd = "/jail",
		reason = "Bagouse (Deagle in Car and etc)",
		time = 300,
	},
	['pk'] = {
		cmd = "/jail",
		reason = "Parkour Mode",
		time = 900,
	},
	['jch'] = {
		cmd = "/jail",
		reason = "Использование читерского ПО/скриптов",
		time = 3000,
	},
	['zv'] = {
		cmd = "/jail",
		reason = "Злоуп. VIP",
		time = 3000,
	},
	['sch'] = {
		cmd = "/jail",
		reason = "Without Damage Scripts",
		time = 900,
	},
	['jcw'] = {
		cmd = '/jail',
		reason = "ClickWarp/Metla",
		time = 900,
	},
	['dbk'] = {
		cmd = '/jail',
		reason = ' ДБ с ковшом (ZZ)',
		time = 900,
	},
	-- ## Команды для выдачи джайла ## -- 
			

	-- ## Команды для выдачи кика ## --

	['dj'] = {
		cmd = "/kick",
		reason = ' DM in /jail',
	},
	['nk1'] = {
		cmd = "/kick",
		reason = ' Смените никнейм. 1/3',
	},
	['nk2'] = {
		cmd = "/kick",
		reason = ' Смените никнейм. 2/3',
	},
	['nk3'] = {
		cmd = "/nak",
		reason = ' Смените никнейм. 3/3',
	},
	['cafk'] = {
		cmd = "/kick",
		reason = ' AFK in /arena',
	},
	-- ## Команды для выдачи кика ## --

            -- ## Команды исключительно для OnLine # --

            -- ## Команды исключительно для OffLine # --

        -- ## Команды для выдачи бана ## --
        ['ahl'] = {
            cmd = '/offban',
            reason = 'Оск/Униж/Мат in Helper',
            time = 3,
        },
        ['ank'] = {
            cmd = '/offban',
            reason = 'Ник с запр.словами',
            time = 7,
        },
        ['ahli'] = {
            cmd = '/banip',
            reason = 'Оск/Униж/Мат in Helper',
            cmd = 3,
        },
        ['aob'] = {
            cmd = '/offban',
            reason = 'Обход бана',
            time = 7,
        },
        ['apl'] = {
            cmd = '/offban',
            reason = 'Плагиат никнейма администратора',
            time = 7,
        },
        ['ach'] = {
            cmd = '/offban',
            reason = 'ИЧС/ПО',
            time = 7,
        },
        ['achi'] = {
            cmd = '/banip',
            reason = 'ИЧС/ПО',
            time = 7,
        },
        ['agk'] = {
            cmd = '/offban',
            reason = 'Банда с нецензурной лексикой',
            time = 7,
        },
        ['obman'] = {
            cmd = '/offban',
            reason = 'Обман администрации/игроков',
            time = 30,
        },
        ['obmanip'] = {
            cmd = '/banip',
            reason = 'Обман администрации/игроков',
            time = 30,
        },
        ['abnm'] = {
            cmd = '/offban',
            reason = 'Неадекватное поведение',
            time = 7,
        },
        -- ## Команды для выдачи бана ## --

        -- ## Команды для выдачи мута ## --
        ['azs'] = {
            cmd = '/muteakk',
            reason = 'Злоуп.символами',
            time = 600,
        },
        ['afd'] = {
            cmd = '/muteakk',
            reason = 'Флуд/Спам',
            time = 120,
        },
        ['apo'] = {
            cmd = '/muteakk',
            reason = 'Попрошайничество',
            time = 120,
        },
        ['am'] = {
            cmd = '/muteakk',
            reason = 'Нецензурная лексика',
            time = 300,
        },
        ['aok'] = {
            cmd = '/muteakk',
            reason = 'Оскорбление/Унижение',
            time = 400,
        },
        ['anm'] = {
            cmd = '/muteakk',
            reason = 'Неадекватное поведение',
            time = 900,
        },
        ['aoa'] = {
            cmd = '/muteakk',
            reason = 'Оск/Унижение адм',
            time = 2500,
        },
        ['aor'] = {
            cmd = '/muteakk',
            reason = 'Оскорбление/Упоминание родных',
            time = 5000,
        },
        ['aup'] = {
            cmd = '/muteakk',
            reason = 'Упом.стор.проектов',
            time = 1000,
        },
        ['aia'] = {
            cmd = '/muteakk',
            reason = 'Выдача себя за адм',
            time = 2500,
        },
        ['akl'] = {
            cmd = '/muteakk',
            reason = 'Клевета на администрацию',
            time = 3000,
        },
        ['arz'] = {
            cmd = '/muteakk',
            reason = 'Розжиг межнац.розни',
            time = 5000,
        },
        -- ## Команды для выдачи мута ## --

        -- ## Команды для выдачи джайла ## --
        ['asch'] = {
            cmd = '/jailakk',
            reason = 'ИЗС',
            time = 900,
        },
        ['ajch'] = {
            cmd = '/jailakk',
            reason = 'ИЧС/ПО',
            time = 3000,
        },
        ['azv'] = {
            cmd = '/jailakk',
            reason = 'Злоуп.VIP',
            time = 3000,
        },
        ['adgw'] = {
            cmd = '/jailakk',
            reason = 'Исп.наркотиков in /gw',
            time = 500,
        },
        ['ask'] = {
            cmd = '/jailakk',
            reason = 'SpawnKill',
            time = 300,
        },
        ['adz'] = {
            cmd = '/jailakk',
            reason = 'DM/DB in zz',
            time = 300,
        },
        ['atd'] = {
            cmd = '/jailakk',
            reason = 'DM/car in /trade',
            time = 300,
        },
        ['amp'] = {
            cmd = '/jailakk',
            reason = 'Нарушение правил MP',
            time = 300,
        },
        ['apmx'] = {
            cmd = '/jailakk',
            reason = 'Серьезная помеха игрокам',
            time = 3000,
        },
        ['askw'] = {
            cmd = '/jailakk',
            reason = 'SK in /gw',
            time = 600,
        },
        ['angw'] = {
            cmd = '/jailakk',
            reason = 'Invalid CMD in /gw',
            time = 600,
        },
        ['adbgw'] = {
            cmd = '/jailakk',
            reason = 'Helicopter in /gw',
            time = 600,
        },
        ['afsh'] = {
            cmd = '/jailakk',
            reason = 'SpeedHack/FlyCar',
            time = 900,
        },
        ['abag'] = {
            cmd = '/jailakk',
            reason = 'Bagouse (deagle in car and etc)',
            time = 300,
        },
        ['apk'] = {
            cmd = '/jailakk',
            reason = 'ParkourMode',
            time = 900,
        },
        ['ajcw'] = {
            cmd = '/jailakk',
            reason = 'ClickWarp/Metla (ИЧС)',
            time = 900,
        },
        -- ## Команды для выдачи джайла ## --
            -- ## Команды исключительно для OffLine # --
}

cmd_helper_others = {
    ['uj'] = {
        reason = ' [ID] - Разджайлить игрока',
    },
    ['uu'] = {
        reason = ' [ID] - Размутить игрока с извинениями',
    },
    ['u'] = {
        reason = ' [ID] - Быстрый размут',
    },
    ['spp'] = {
        reason = ' - Заспавнить всех в зоне стрима',
    },
    ['akill'] = {
        reason = ' [ID] - Убить игрока',
    },
    ['aheal'] = {
        reason = ' [ID] - Отхилить игрока',
    },
    ['ru'] = {
        reason = ' [ID] - Размут репорта',
    },
    ['as'] = {
        reason = ' [ID] - Заспавнить игрока',
    },
    ['rcl'] = {
        reason = ' - Очистка чата для Вас',
    },
	['prfm'] = {
		reason = ' [ID] - Выдача префикса младшему админу',
	},
	['prfad'] = {
		reason = ' [ID] - Выдача префикса обычному админу',
	},
	['prfst'] = {
		reason = ' [ID] - Выдача префикса старшему админу',
	},
	['prfzga'] = {
		reason = ' [ID] - Выдача префикса ЗГА',
	},
	['prfga'] = {
		reason = ' [ID] - Выдача префикса ГА',
	},
	['stw'] = {
		reason = ' [ID] - Выдача минигана челику',
	},
	['tool'] = {
		reason = ' - Запуск основного интерфейса АТ',
	},
}

cmd_helper_answers = {
	['ngm'] = {
        reason = ' [ID] - Данный игрок покинул игру.',
    },
	['tcm'] = {
        reason = ' [ID] - Чтобы обменять валюту, введите /trade, и подойдите к NPC Арману, стоит справа',
    },
	['tm'] = {
        reason = ' [ID] - Ожидайте.',
    },
	['zsk'] = {
        reason = ' [ID] - Если вы застряли, введите /spawn | /kill, но мы можем вам помочь!',
    },
	['vgf'] = {
        reason = ' [ID] - Чтобы выдать выговор участнику банды, есть команда: /gvig',
    },
	['html'] = {
        reason = ' [ID] - https://colorscheme.ru/html-colors.html',
    },
	['ktp'] = {
        reason = ' [ID] - /tp (по локациям), /g (/goto) id (к игроку) с VIP (/help -> 7 пункт)',
    },
	['vp1'] = {
        reason = ' [ID] - Данный игрок с привелегией Premuim VIP (/help -> 7)',
    },
	['vp2'] = {
        reason = ' [ID] - Данный игрок с привелегией Diamond VIP (/help -> 7)',
    },
	['vp3'] = {
        reason = ' [ID] - Данный игрок с привелегией Platinum VIP (/help -> 7)',
    },
	['vp4'] = {
        reason = ' [ID] - Данный игрок с привелегией «Личный» VIP (/help -> 7)',
    },
	['chap'] = {
        reason = ' [ID] - /mm -> Действия -> Сменить пароль',
    },
	['msp'] = {
        reason = ' [ID] - /mm -> Транспортное средство -> Тип транспорта',
    },
	['trp'] = {
        reason = ' [ID] - /report',
    },
	['rid'] = {
        reason = ' [ID] - Уточните ID нарушителя/читера в /report',
    },
	['bk'] = {
        reason = ' [ID] - Оплатить бизнес/дом можно с помощью /bank или /tp -> Разное -> Банк',
    },
	['h7'] = {
        reason = ' [ID] - Посмотреть информацию можно в /help -> 7 пункт.',
    },
	['h8'] = {
        reason = ' [ID] - Узнать данную информацию можно в /help -> 8 пункт.',
    },
	['h14'] = {
        reason = ' [ID] - Узнать данную информацию можно в /help -> 14 пункт.',
    },
	['zba'] = {
        reason = ' [ID] - Админ наказал не так? Пишите жалобу на форум https://forumrds.ru',
    },
	['zbp'] = {
        reason = ' [ID] - Пишите жалобу на игрока на форум https://forumrds.ru',
    },
	['avt'] = {
        reason = ' [ID] - /tp -> Разное -> Автосалоны | Приятной игры!',
    },
	['avt1'] = {
        reason = ' [ID] - /tp -> Разное -> Автосалоны -> Автомастерская | Приятной игры!',
    },
	['pgf'] = {
        reason = ' [ID] - /gleave (банда) || /fleave (семья)',
    },
	['lgf'] = {
        reason = ' [ID] - /leave (покинуть мафию) | Приятной игры на RDS <3',
    },
	['igf'] = {
        reason = ' [ID] - /ginvite (банда) || /finvite (семья)',
    },
	['ugf'] = {
        reason = ' [ID] - /guninvite (банда) || /funinvite (семья)',
    },
	['cops'] = {
        reason = ' [ID] - 265-267, 280-286, 288, 300-304, 306, 307, 309-311',
    },
	['bal'] = {
        reason = ' [ID] - 102-104',
    },
	['cro'] = {
        reason = ' [ID] - 105-107',
    },
	['rumf'] = {
        reason = ' [ID] - 111-113',
    },
	['vg'] = {
        reason = ' [ID] - 108-110',
    },
	['var'] = {
        reason = ' [ID] - 114-116',
    },
	['triad'] = {
        reason = ' [ID] - 117-118, 120',
    },
	['mf'] = {
        reason = ' [ID] - 124-127',
    },
	['gvm'] = {
        reason = ' [ID] - Для перевода денег, необхдимо ввести /givemoney IDPlayer сумму',
    },
	['gvs'] = {
        reason = ' [ID] - Для перевода очков, необходимо ввести /givescore IDPlayer сумму',
    },
	['cpt'] = {
        reason = ' [ID] - Для того, чтобы начать капт, нужно ввести /capture',
    },
	['psv'] = {
        reason = ' [ID] - /passive - пассивный режим, для того, чтобы вас не могли убить.',
    },
	['dis'] = {
        reason = ' [ID] - Игрок не в сети.',
    },
	['nac'] = {
        reason = ' [ID] - Игрок наказан.',
    },
	['cl'] = {
        reason = ' [ID] - Данный игрок чист.',
    },
	['yt'] = {
        reason = ' [ID] - Уточните вашу жалобу/вопрос.',
    },
	['drb'] = {
        reason = ' [ID] - /derby - записатся на дерби',
    },
	['smc'] = {
        reason = ' [ID] - /sellmycar IDPlayer Слот(1-3) RDScoin (игроку), в гос: /car',
    },
	['c'] = {
        reason = ' [ID] - Начал(а) работу по вашей жалобе.',
    },
	['stp'] = {
        reason = ' [ID] - Чтобы посмотреть коины, вирты, рубли и т.д. - /statpl',
    },
	['prk'] = {
        reason = ' [ID] - /parkour - записатся на паркур ',
    },
	['n'] = {
        reason = ' [ID] - Не вижу нарушений от игрока.',
    },
	['hg'] = {
        reason = ' [ID] - Помогли вам.',
    },
	['int'] = {
        reason = ' [ID] -  Данную информацию можно узнать в интернете.',
    },
	['og'] = {
        reason = ' [ID] - стать на пикап "Ограбление банка", после около ячеек нажимать на ALT и ехать на красный маркер на карте',
    },
	['msid'] = {
        reason = ' [ID] - Наказание будет снято. Ошибка ID',
    },
	['al'] = {
        reason = ' [ID] - Администратор, введите /alogin',
    },
	['gfi'] = {
        reason = ' [ID] - /funinvite id (в семью), /ginvite id (в банду)',
    },
	['hin'] = {
		reason = ' [ID] - /hpanel -> Слот1-3 -> Изменить -> Аренда дома',
	},
	['gn'] = {
		reason = ' [ID] - /menu (/mm) - ALT/Y -> Оружие',
	},
	['pd'] = {
		reason = ' [ID] - /menu (/mm) - ALT/Y -> Предметы',
	},
	['dtl'] = {
		reason = ' [ID] - Детали разбросаны по всей карте. Обмен происходится на /garage.',
	},
	['nz'] = {
		reason = ' [ID] - Не запрещено.',
	},
	['y'] = {
		reason = ' [ID] - Да.',
	},
	['net'] = {
		reason = ' [ID] - Нет.',
	},
	['gak'] = {
		reason = ' [ID] - Продать аксессуары, или купить можно на /trade. Чтобы продать, F у лавки ',
	},
	['fp'] = {
		reason = ' [ID] - /familypanel',
	},
	['mg'] = {
		reason = ' [ID] - /menu (/mm) - ALT/Y -> Система банд',
	},
	['pg'] = {
		reason = ' [ID] - Проверим.',
	},
	['krb'] = {
		reason = ' [ID] - Казино, работы, бизнес.',
	},
	['kmd'] = {
		reason = ' [ID] - Казино, МП, достижения, работы, обмен очков на коины(/trade)',
	},
	['gm'] = {
		reason = ' [ID] - GodMode (ГодМод) на сервере не работает.',
	},
	['plg'] = {
		reason = ' [ID] - Попробуйте перезайти.',
	},
	['nv'] = {
		reason = ' [ID] - Не выдаем.',
	},
	['of'] = {
		reason = ' [ID] - Не оффтопьте.',
	},
	['en'] = {
		reason = ' [ID] - Не знаем.',
	},
	['vbg'] = {
		reason = ' [ID] - Скорей всего - это баг.',
	},
	['ctun'] = {
		reason = ' [ID] - /menu (/mm) - ALT/Y -> Т/С -> Тюнинг',
	},
	['cr'] = {
		reason = ' [ID] - /car',
	},
	['zsk'] = {
		reason = ' [ID] - Если вы застряли, введите /spawn | /kill',
	},
	['smh'] = {
		reason = ' [ID] - /sellmyhouse (игроку)  ||  /hpanel -> слот -> Изменить -> Продать дом государству',
	},
	['gadm'] = {
		reason = ' [ID] - Ожидать набор, или же /help -> 18 пункт.',
	},
	['hct'] = {
		reason = ' [ID] - /count time || /dmcount time',
	},
	['gvr'] = {
		reason = ' [ID] - /giverub IDPlayer rub | С Личного (/help -> 7)',
	},
	['gvc'] = {
		reason = ' [ID] - /givecoin IDPlayer coin | С Личного (/help -> 7)',
	},
	['tdd'] = {
		reason = ' [ID] - /dt 0-990 / Виртуальный мир',
	},
}