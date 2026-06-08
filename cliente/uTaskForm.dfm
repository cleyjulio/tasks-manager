object frmTask: TfrmTask
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Nova Tarefa'
  ClientHeight = 290
  ClientWidth = 508
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  DesignSize = (
    508
    290)
  TextHeight = 15
  object lblTitulo: TLabel
    Left = 16
    Top = 14
    Width = 33
    Height = 15
    Caption = 'Titulo:'
  end
  object lblDescricao: TLabel
    Left = 16
    Top = 68
    Width = 54
    Height = 15
    Caption = 'Descricao:'
  end
  object lblPrioridade: TLabel
    Left = 16
    Top = 168
    Width = 57
    Height = 15
    Caption = 'Prioridade:'
  end
  object edtTitulo: TEdit
    Left = 16
    Top = 34
    Width = 476
    Height = 23
    Anchors = [akLeft, akTop, akRight]
    MaxLength = 200
    TabOrder = 0
  end
  object memDescricao: TMemo
    Left = 16
    Top = 88
    Width = 476
    Height = 68
    Anchors = [akLeft, akTop, akRight]
    ScrollBars = ssVertical
    TabOrder = 1
  end
  object cboPrioridade: TComboBox
    Left = 16
    Top = 188
    Width = 160
    Height = 23
    Style = csDropDownList
    ItemIndex = 0
    TabOrder = 2
    Text = '1 - Muito Alta'
    Items.Strings = (
      '1 - Muito Alta'
      '2 - Alta'
      '3 - M'#233'dia'
      '4 - Baixa'
      '5 - Muito Baixa')
  end
  object chkPrazo: TCheckBox
    Left = 196
    Top = 191
    Width = 97
    Height = 17
    Caption = 'Tem prazo'
    TabOrder = 3
    OnClick = chkPrazoClick
  end
  object dtpPrazo: TDateTimePicker
    Left = 310
    Top = 186
    Width = 182
    Height = 23
    Date = 46010.00000000000000000
    Time = 46010.00000000000000000
    Enabled = False
    TabOrder = 4
  end
  object pnlButtons: TPanel
    Left = 0
    Top = 242
    Width = 508
    Height = 48
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 5
    object btnOk: TButton
      Left = 333
      Top = 10
      Width = 75
      Height = 28
      Caption = 'OK'
      Default = True
      TabOrder = 0
      OnClick = btnOkClick
    end
    object btnCancel: TButton
      Left = 417
      Top = 10
      Width = 75
      Height = 28
      Cancel = True
      Caption = 'Cancelar'
      ModalResult = 2
      TabOrder = 1
    end
  end
end
