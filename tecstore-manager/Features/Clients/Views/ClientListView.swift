import SwiftUI

// MARK: - ClientListView

struct ClientListView: View {
    @ObservedObject var viewModel: ClientListViewModel
    let onAdd: () -> Void
    let onEdit: (Cliente) -> Void

    var body: some View {
        VStack(spacing: 0) {
            ClientSearchBar(text: $viewModel.searchText)

            Divider()

            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.clients.isEmpty {
                EmptyClientsView(searchText: viewModel.searchText)
            } else {
                List {
                    ForEach(viewModel.clients) { client in
                        ClientRowView(client: client)
                            .contentShape(Rectangle())
                            .onTapGesture { onEdit(client) }
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
            }
        }
        .navigationTitle("Clientes")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: onAdd) {
                    Image(systemName: "plus")
                        .fontWeight(.semibold)
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
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.15))
                    .frame(width: 44, height: 44)
                Text(
                    String(client.nombres.prefix(1)) +
                    String(client.apellidos.prefix(1))
                )
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.blue)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text("\(client.nombres) \(client.apellidos)")
                    .font(.headline)
                    .lineLimit(1)
                Text("DNI: \(client.dni)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                if let telefono = client.telefono, !telefono.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "phone.fill")
                            .font(.caption2)
                        Text(telefono)
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                }
            }

            Spacer()

            Circle()
                .fill(client.estado ? Color.green : Color.red)
                .frame(width: 10, height: 10)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - ClientSearchBar

private struct ClientSearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            TextField("Buscar por nombre o DNI...", text: $text)
                .autocorrectionDisabled()
            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(10)
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}

// MARK: - EmptyClientsView

private struct EmptyClientsView: View {
    let searchText: String

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.2")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            Text(
                searchText.isEmpty
                    ? "No hay clientes"
                    : "Sin resultados para \"\(searchText)\""
            )
            .font(.headline)
            .foregroundColor(.secondary)
            if searchText.isEmpty {
                Text("Toca + para agregar uno")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}
