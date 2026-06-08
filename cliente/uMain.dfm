object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'Gerenciador de Tarefas'
  ClientHeight = 600
  ClientWidth = 750
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 15
  object pnlStats: TPanel
    Left = 0
    Top = 0
    Width = 750
    Height = 121
    Align = alTop
    BevelOuter = bvNone
    Color = 4210752
    ParentBackground = False
    TabOrder = 0
    object Shape4: TShape
      Left = 478
      Top = 15
      Width = 153
      Height = 91
      Brush.Color = 4144959
      Pen.Style = psClear
      Shape = stRoundRect
    end
    object Shape3: TShape
      Left = 319
      Top = 15
      Width = 153
      Height = 91
      Brush.Color = 4144959
      Pen.Style = psClear
      Shape = stRoundRect
    end
    object Shape2: TShape
      Left = 160
      Top = 15
      Width = 153
      Height = 91
      Brush.Color = 4144959
      Pen.Style = psClear
      Shape = stRoundRect
    end
    object Shape1: TShape
      Left = 1
      Top = 15
      Width = 153
      Height = 91
      Brush.Color = 4144959
      Pen.Style = psClear
      Shape = stRoundRect
    end
    object lblAtrasadas: TLabel
      Left = 168
      Top = 29
      Width = 136
      Height = 37
      Alignment = taCenter
      AutoSize = False
      Caption = 'NAtr'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clRed
      Font.Height = -27
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      StyleElements = []
    end
    object lblConcluidas: TLabel
      Left = 330
      Top = 29
      Width = 130
      Height = 37
      Alignment = taCenter
      AutoSize = False
      Caption = 'NConc'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clLime
      Font.Height = -27
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      StyleElements = []
    end
    object lblMedia: TLabel
      Left = 490
      Top = 34
      Width = 127
      Height = 31
      Alignment = taCenter
      AutoSize = False
      Caption = 'NMedia'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 4227327
      Font.Height = -27
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      StyleElements = []
    end
    object Label1: TLabel
      Left = 32
      Top = 77
      Width = 86
      Height = 15
      Caption = 'Total de tarefas'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label2: TLabel
      Left = 209
      Top = 77
      Width = 53
      Height = 15
      Caption = 'Atrasadas'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label3: TLabel
      Left = 330
      Top = 71
      Width = 127
      Height = 30
      Alignment = taCenter
      Caption = 'Conclu'#237'das nos '#250'ltimos 7 dias'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      WordWrap = True
      StyleElements = []
    end
    object lblTotal: TLabel
      Left = 8
      Top = 34
      Width = 136
      Height = 37
      Alignment = taCenter
      AutoSize = False
      Caption = 'NTotal'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -27
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      StyleElements = []
    end
    object Label4: TLabel
      Left = 490
      Top = 71
      Width = 123
      Height = 30
      Alignment = taCenter
      Caption = 'M'#233'dia das prioridades (N'#227'o conclu'#237'das)'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      WordWrap = True
      StyleElements = []
    end
    object btnRefresh: TButton
      Left = 644
      Top = 47
      Width = 96
      Height = 28
      Caption = 'Atualizar'
      TabOrder = 0
      OnClick = btnRefreshClick
    end
  end
  object grdTarefas: TStringGrid
    Left = 0
    Top = 121
    Width = 750
    Height = 431
    Align = alClient
    ColCount = 6
    FixedCols = 0
    RowCount = 2
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRowSelect]
    ScrollBars = ssVertical
    TabOrder = 1
    OnSelectCell = grdTarefasSelectCell
  end
  object pnlBottom: TPanel
    Left = 0
    Top = 552
    Width = 750
    Height = 48
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    object lblStatusLabel: TLabel
      Left = 192
      Top = 14
      Width = 35
      Height = 15
      Caption = 'Status:'
    end
    object btnNew: TButton
      Left = 1
      Top = 8
      Width = 100
      Height = 28
      Caption = 'Nova Tarefa'
      TabOrder = 0
      OnClick = btnNewClick
    end
    object btnEdit: TButton
      Left = 109
      Top = 8
      Width = 75
      Height = 28
      Caption = 'Editar'
      TabOrder = 4
      OnClick = btnEditClick
    end
    object cboStatus: TComboBox
      Left = 222
      Top = 10
      Width = 150
      Height = 23
      Style = csDropDownList
      TabOrder = 1
      Items.Strings = (
        'N'#227'o iniciada'
        'Em andamento'
        'Concluida')
    end
    object btnApplyStatus: TButton
      Left = 380
      Top = 8
      Width = 120
      Height = 28
      Caption = 'Aplicar Status'
      TabOrder = 2
      OnClick = btnApplyStatusClick
    end
    object btnDelete: TButton
      Left = 508
      Top = 8
      Width = 100
      Height = 28
      Caption = 'Excluir'
      TabOrder = 3
      OnClick = btnDeleteClick
    end
  end
end
