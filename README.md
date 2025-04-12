# 📱 **Sistema de Gerenciamento de Estoque com Flutter**  

Um aplicativo mobile completo para **controle de estoque, vendas e emissão de notas fiscais em PDF**, desenvolvido em Flutter com banco de dados SQLite e integração com scanner de código de barras.  

---

## 🚀 **Funcionalidades**  

✅ **Cadastro de Produtos**  
- Descrição, código de barras, preço de compra/venda (+40%), quantidade em estoque  
- Histórico de última compra/venda  

🔍 **Scanner de Código de Barras**  
- Consulta rápida de produtos  
- Cadastro automático de novos produtos  

💰 **Sistema de Vendas**  
- Adição de múltiplos itens  
- Cálculo automático do total  
- Registro de vendedor e cliente  

📄 **Geração de Nota Fiscal em PDF**  
- Dados da empresa, itens vendidos, totais  
- Opção de compartilhar ou imprimir  

📊 **Relatórios**  
- Estoque atualizado  
- Histórico de vendas  

---

## 🛠 **Tecnologias Utilizadas**  

- **Flutter** (Framework multiplataforma)  
- **SQLite** (Banco de dados local)  
- **Mobile Scanner** (Leitura de código de barras)  
- **PDF & Printing** (Geração de PDF)  
- **Intl** (Formatação de datas/valores)  

---

## 📦 **Como Executar o Projeto**  

1. **Pré-requisitos**  
   - Flutter SDK instalado ([Guia de instalação](https://flutter.dev/docs/get-started/install))  
   - Android Studio/Xcode (para emulador)  

2. **Clonar o repositório**  
   ```bash
   git clone https://github.com/seu-usuario/estoque-flutter.git
   cd estoque-flutter
   ```

3. **Instalar dependências**  
   ```bash
   flutter pub get
   ```

4. **Executar o app**  
   ```bash
   flutter run
   ```

---

## 📂 **Estrutura do Projeto**  

```
lib/
├── models/          # Modelos de dados (Produto, Venda, ItemVenda)
├── database/        # Configuração do SQLite (CRUD)
├── screens/         # Telas do aplicativo
├── services/        # Serviços (PDF, Scanner)
└── widgets/         # Componentes reutilizáveis
```

---

## 📸 **Capturas de Tela**  

<p>
  <img src="https://github.com/user-attachments/assets/ef8edb98-357b-4bcc-9cdb-77b79b9817e8" width="200" />
  <img src="https://github.com/user-attachments/assets/2936d42e-b2c1-4595-9eb0-52df68324e59" width="200" />
  <img src="https://github.com/user-attachments/assets/2a9bbb9c-7299-493b-8297-002c38f19540" width="200" />
  <img src="https://github.com/user-attachments/assets/dcdc71ef-6c7d-4394-81a8-b6a908fe4b23" width="200" />
</p>


---

## 📝 **Licença**  

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.  

---

## 💡 **Próximas Atualizações**  

- [ ] Sincronização com Firebase/API  
- [ ] Autenticação de usuários  
- [ ] Dashboard de métricas  

---

**Feito com ❤️ por [Seu Nome]**  
🔗 *Me siga no [LinkedIn](https://www.linkedin.com/in/raimundo-victor-cruz-563897256/) | [GitHub](https://github.com/RVictorCruz)*  

--- 

**👉 Quer contribuir?** Abra uma *issue* ou envie um *pull request*! 🚀  
