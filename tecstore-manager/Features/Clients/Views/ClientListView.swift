import SwiftUI

// MARK: - ClientListView

struct ClientListView: View {
    @ObservedObject var viewModel: ClientListViewModel
    let onAdd: () -> Void
    let onEdit: (Cliente) -> Void

    var body: some View {
        VStack(spacing: 0) {

            // MARK: Search bar
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(AppColors.textSecondary)
                TextField("Buscar por nombre o DNI...", text: $viewModel.searchText)
                    .font(AppFonts.body())
                    .autocorrectionDisabled()
                if !viewModel.searchText.isEmpty {
                    Button {
                        viewModel.searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(AppColors.textTertiary)
                    }
                }
            }
            .padding(.horizontal, 14).padding(.vertical, 11)
            .background(AppColors.cardBackground)
            .cornerRadius(14)
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 8)

            Divider()

            if viewModel.isLoading {
                ProgressView()
                    .tint(AppColors.primary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.clients.isEmpty {
                EmptyClientsView(searchText: viewModel.searchText)
            } else {
                List {
                    ForEach(viewModel.clients) { client in
                        ClientRowView(client: client)
                            .contentShape(Rectangle())
                            .onTapGesture { onEdit(client) }
                            .listRowBackground(AppColors.cardBackground)
                            .listRowSeparatorTint(AppColors.textTertiary.opacity(0.3))
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    viewModel.deleteClient(id: client.id)
                                } label: {
                                    Label("Eliminar", systemImage: "trash")
                                }
                            }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(AppColors.pageBackground)
            }
        }
        .background(AppColors.pageBackground.ignoresSafeArea())
        .navigationTitle("Clientes")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: onAdd) {
                    Image(systemName: "plus")
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.primary)
                }
            }
        }
        .onAppear { viewModel.loadClients() }
    }
}

// MARK: - ClientRowView

struct ClientRowView: View {
    let client: Cliente

    var body: some View {
        HStack(spacing: 12) {

            // Gradient avatar
            ZStack {
                Circle()
                    .fill(AppColors.gradientPrimary)
                    .frame(width: 48, height: 48)
                Text(initials(client))
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("\(client.nombres) \(client.apellidos)")
                    .font(AppFonts.headline())
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(1)
                Text("DNI: \(client.dni)")
                    .font(AppFonts.caption())
                    .foregroundColor(AppColors.textSecondary)
                if let telefono = client.telefono, !telefono.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "phone.fill")
                            .font(.system(size: 9))
                        Text(telefono)
                            .font(AppFonts.caption2())
                    }
                    .foregroundColor(AppColors.textTertiary)
                }
            }

            Spacer()

            Text(client.estado ? "Activo" : "Inactivo")
                .font(AppFonts.caption2())
                .padding(.horizontal, 8).padding(.vertical, 3)
                .background(client.estado
                             ? AppColors.success.opacity(0.12)
                             : AppColors.danger.opacity(0.12))
                .foregroundColor(client.estado ? AppColors.success : AppColors.danger)
                .cornerRadius(8)
        }
        .padding(.vertical, 4)
    }

    private func initials(_ client: Cliente) -> String {
        let n = client.nombres.first.map(String.init) ?? ""
        let a = client.apellidos.first.map(String.init) ?? ""
        return (n + a).uppercased()
    }
}

// MARK: - EmptyClientsView

private struct EmptyClientsView: View {
    let searchText: String

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(AppColors.primary.opacity(0.05))
                    .frame(width: 120, height: 120)
                Circle()
                    .fill(AppColors.primary.opacity(0.08))
                    .frame(width: 90, height: 90)
                Image(systemName: "person.2")
                    .font(.system(size: 44))
                    .foregroundColor(AppColors.primary.opacity(0.5))
            }
            Text(searchText.isEmpty
                 ? "No hay clientes registrados"
                 : "Sin resultados para «\(searchText)»")
                .font(AppFonts.headline())
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
            if searchText.isEmpty {
                Text("Toca + para agregar el primer cliente")
                    .font(AppFonts.caption())
                    .foregroundColor(AppColors.textTertiary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}
